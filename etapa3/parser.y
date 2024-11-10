%{
    #include <stdio.h>
    int yylex(void);
    void yyerror (char const *mensagem);
    int get_line_number();
    extern void *arvore;
%}

%code requires { 
    #include "asd.h" 
    #include "valor_lexico.h" 
}

%union{
    asd_tree_t *arvore;
    valor_lexico_t *valor_lexico;
}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_IF
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_RETURN
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token<valor_lexico> TK_IDENTIFICADOR
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token TK_ERRO

%type<arvore> programa
%type<arvore> lista_de_funcoes
%type<arvore> funcao
%type<arvore> cabecalho
%type<arvore> lista_de_parametros
%type<arvore> parametro
%type<arvore> corpo
%type<arvore> bloco_comandos
%type<arvore> sequencia_de_comandos
%type<arvore> comando_simples
%type<arvore> declaracao_variavel
%type<arvore> lista_de_identificadores
%type<arvore> identificador
%type<arvore> comando_atribuicao
%type<arvore> chamada_funcao
%type<arvore> lista_argumentos
%type<arvore> argumento
%type<arvore> comando_retorno
%type<arvore> comando_controle_fluxo
%type<arvore> expressao
%type<arvore> expr7
%type<arvore> expr6
%type<arvore> expr5
%type<arvore> expr4
%type<arvore> expr3
%type<arvore> expr2
%type<arvore> expr1
%type<arvore> operando

%define parse.error verbose

%%

programa: lista_de_funcoes | /* vazio */;
lista_de_funcoes: lista_de_funcoes funcao | funcao;

// utils
tipo: TK_PR_INT | TK_PR_FLOAT;
literal: TK_LIT_FLOAT | TK_LIT_INT;

//funcao
funcao: cabecalho corpo;

cabecalho: TK_IDENTIFICADOR '=' lista_de_parametros '>' tipo | 
           TK_IDENTIFICADOR '=' '>' tipo; 
lista_de_parametros: lista_de_parametros TK_OC_OR parametro | parametro;
parametro: TK_IDENTIFICADOR '<' '-' tipo;

corpo: bloco_comandos;

//3.2
bloco_comandos: '{' '}' | 
                '{' sequencia_de_comandos '}';
sequencia_de_comandos: sequencia_de_comandos comando_simples ';'|
                       comando_simples ';';

//3.3
comando_simples: bloco_comandos |  
                 declaracao_variavel | 
                 comando_atribuicao | 
                 chamada_funcao | 
                 comando_retorno |
                 comando_controle_fluxo;

    //3.3.1 declaracao de variavel
declaracao_variavel: tipo lista_de_identificadores;
lista_de_identificadores: identificador | 
                          lista_de_identificadores ',' identificador;
identificador: TK_IDENTIFICADOR | TK_IDENTIFICADOR TK_OC_LE literal;
    
    //3.3.2 comando de atribuicao
comando_atribuicao: TK_IDENTIFICADOR '=' expressao;

    //3.3.3 chamada de funcao
chamada_funcao: TK_IDENTIFICADOR '(' lista_argumentos ')';
lista_argumentos: lista_argumentos ',' argumento | argumento;
argumento: expressao;

    //3.3.4 comando de retorno
comando_retorno: TK_PR_RETURN expressao;

    //3.3.5 comando de controle de fluxo
comando_controle_fluxo: TK_PR_IF '(' expressao ')' bloco_comandos |
                        TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos |
                        TK_PR_WHILE '(' expressao ')' bloco_comandos;
//expr
expressao: expr7 { $$ = $1; };

expr7: expr7 TK_OC_OR expr6 {$$ = asd_new("|"); asd_add_child($$,$1); asd_add_child($$,$3);}
| expr6 { $$ = $1; };

expr6: expr6 TK_OC_AND expr5 { $$ = asd_new("&"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr5 { $$ = $1; };

expr5: expr5 TK_OC_NE expr4 { $$ = asd_new("!="); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr5 TK_OC_EQ expr4 { $$ = asd_new("=="); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr4 { $$ = $1; };

expr4: expr4 '<' expr3 { $$ = asd_new("<"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr4 '>' expr3 { $$ = asd_new(">"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr4 TK_OC_LE expr3 { $$ = asd_new("<="); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr4 TK_OC_GE expr3 { $$ = asd_new(">="); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr3 { $$ = $1; };


expr3: expr3 '+' expr2 { $$ = asd_new("+"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr3 '-' expr2 { $$ = asd_new("-"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr2 { $$ = $1; };

expr2: expr2 '*' expr1 { $$ = asd_new("*"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr2 '/' expr1 { $$ = asd_new("/"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr2 '%' expr1 { $$ = asd_new("%"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr1 { $$ = $1;};

expr1: '-' operando { $$ = asd_new("-"); asd_add_child($$,$2); }
| '!' operando { $$ = asd_new("!"); asd_add_child($$,$2); }
| operando { $$ = $1; };


operando: TK_IDENTIFICADOR { $$ = asd_new($1->valor); }
| TK_LIT_FLOAT { $$ = asd_new($1->valor); }
| TK_LIT_INT { $$ = asd_new($1->valor); }
| chamada_funcao  { $$ = $1; }
|'(' expressao ')' { $$ = $2; };

%%

void yyerror(char const *mensagem)
{
    fprintf(stderr, "%s on line %d\n", mensagem, get_line_number());
}
