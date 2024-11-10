%{
    #include <stdio.h>
    int yylex(void);
    void yyerror (char const *mensagem);
    int get_line_number();
    extern void *arvore;

    typedef struct valor_lexico {
       int linha;
       short tipo; //0-ID 1-LIT_INT 2-LIT_FLOAT
       char *valor;
    } valor_lexico_t;
%}

%code requires { #include "asd.h" }
%union{
    asd_tree_t *arvore;
    valor_lexico_t valor_lexico;

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

%define parse.error verbose

%%

/* ===== PROGRAMA ============================ */
programa: lista_de_funcoes | /* vazio */;
lista_de_funcoes: lista_de_funcoes funcao | funcao;

/* ===== FUNCAO ======================= */
funcao: cabecalho corpo;

// utils
tipo: TK_PR_INT | TK_PR_FLOAT;
literal: TK_LIT_FLOAT | TK_LIT_INT;

op5: TK_OC_EQ | TK_OC_NE;
op4: '<' | '>' | TK_OC_LE | TK_OC_GE;
op3: '+' | '-';
op2: '*' | '/' | '%';
op1: '-' | '!';




cabecalho: 
    TK_IDENTIFICADOR '=' lista_de_parametros '>' tipo 
    |  TK_IDENTIFICADOR '=' '>' tipo 
; 
lista_de_parametros: 
    lista_de_parametros TK_OC_OR parametro 
    | parametro;
parametro: 
    TK_IDENTIFICADOR '<' '-' tipo;

corpo: bloco_comandos;

//3.2
bloco_comandos: 
    '{' '}' 
    |  '{' sequencia_de_comandos '}';
sequencia_de_comandos: 
    sequencia_de_comandos comando_simples ';'
    | comando_simples ';';

//3.3
comando_simples: 
    bloco_comandos 
    | declaracao_variavel 
    | comando_atribuicao 
    | chamada_funcao 
    | comando_retorno
    | comando_controle_fluxo;

/* ===== VARIAVEIS  ======================= */
// <item> 3.3.1 declaracao de variavel </item > 
declaracao_variavel: tipo lista_de_identificadores;

lista_de_identificadores:
    lista_de_identificadores ',' identificador
    | identificador ; 

identificador: 
    TK_IDENTIFICADOR 
    | TK_IDENTIFICADOR TK_OC_LE literal; 
    
//<item> 3.3.2 comando de atribuicaol </item > 
comando_atribuicao: TK_IDENTIFICADOR '=' expressao;

//3.3.3 chamada de funcao
chamada_funcao: TK_IDENTIFICADOR '(' lista_argumentos ')';
lista_argumentos: lista_argumentos ',' argumento | argumento;
argumento: expressao;

//3.3.4 comando de retorno
comando_retorno: TK_PR_RETURN expressao;

//3.3.5 comando de controle de fluxo
comando_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos 
    | TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos 
    | TK_PR_WHILE '(' expressao ')' bloco_comandos;
//expr
expressao: expr7 ;
expr7: 
    expr7 TK_OC_OR expr6 
    | expr6;
expr6: 
    expr6 TK_OC_AND expr5 
    | expr5;
expr5: 
    expr5 op5 expr4 
    |   expr4;
expr4: 
    expr4 op4 expr3 
    | expr3
;
expr3: 
    expr3 op3 expr2 
    | expr2
;
expr2: 
    expr2 op2 expr1 
    | expr1
;
expr1: 
    op1 operando 
    |   operando
;

operando: 
    TK_IDENTIFICADOR 
    | literal 
    | chamada_funcao 
    | '(' expressao ')'
;
%%

void yyerror(char const *mensagem)
{
    fprintf(stderr, "%s on line %d\n", mensagem, get_line_number());
}
