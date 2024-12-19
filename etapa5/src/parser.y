%{
    #include <string.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include "table.h"
    int yylex(void);
    void yyerror (char const *mensagem);
    int get_line_number();
    extern void *arvore;
    extern SymbolTableStack *stack;

    /*
     * [Engenharia de Software]
     * Funções auxiliares: Declaradas no final do arquivo
        * handleAtribuicao: lida com a declaração de variáveis
        * cria_label_func: cria uma label para a chamada de uma função
        * make_IDENTIFICADOR: cria uma árvore para um identificador
        * yyerror: função chamada quando ocorre um erro de sintaxe (Bison default)
        * 
    */
    # include "valor_lexico.h"
    # include "asd.h"
    # include "iloc.h"
    char *cria_label_func(char *identificador);
    asd_tree_t *handleAtribuicao(void *stack, valor_lexico_t *vl);


    /* Macros */
    #ifdef ASD_PRINT_GRAPHVIZ_FLAG
        // #define GRAPHVIZ_PRINT asd_print_graphviz(arvore);
        #define GRAPHVIZ_PRINT // Não faz nada
    #else
        #define GRAPHVIZ_PRINT // Não faz nada
    #endif
    
%}

%code requires { 
    #include "asd.h" 
    #include "valor_lexico.h" 
    #include "table.h"
    #include "errors.h"
    #include "iloc.h"
}

%union{
    asd_tree_t *arvore;
    valor_lexico_t *valor_lexico;
    TipoDado tiposvar;
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

%type<arvore>  programa
%type<arvore>  lista_de_funcoes
%type<arvore>  funcao
%type<arvore>  cabecalho
%type<arvore>  lista_de_parametros
%type<arvore>  parametro
%type<arvore>  corpo
%type<arvore>  bloco_comandos_Func
%type<arvore>  bloco_comandos
%type<arvore>  sequencia_de_comandos
%type<arvore>  comando_simples
%type<arvore>  declaracao_variavel
%type<arvore>  lista_de_identificadores
%type<arvore>  identificador
%type<arvore>  comando_atribuicao
%type<arvore>  chamada_funcao
%type<arvore>  lista_argumentos
%type<arvore>  comando_retorno
%type<arvore>  comando_controle_fluxo
%type<arvore>  expressao
%type<arvore>  expr_or
%type<arvore>  expr_and
%type<arvore>  expr_eq
%type<arvore>  expr_rel
%type<arvore>  expr_add
%type<arvore>  expr_mult
%type<arvore>  expr_unary
%type<arvore>  primary
%type<tiposvar> tipo

%define parse.error verbose

%%



main: cria_escopo_global programa destroi_escopo_global;


/*============= TABLE ACTIONS ============================= */
cria_escopo_global:
{
    stack = create_stack();
    push_table(&stack);
    stack->table->deslocamento = 0;
    #ifdef DVERBOSE
    printf("==================foo!\n");
    #endif
};

destroi_escopo_global: 
{
    // print_stack(stack);
    free_stack(stack);
};

empilha_tabela: 
{
    int deslocamento = (stack->table->deslocamento) ? stack->table->deslocamento : 0;
    push_table(&stack);
     stack->table->deslocamento =  stack->table->deslocamento ;
    if(stack->table){
        stack->table->deslocamento = deslocamento;
    }
    // print_stack(stack->table);
};

desempilha_tabela: 
{
    print_stack(stack);
    // printf("\n ##>>>>>>Deslocamento: %d\n",stack->table->deslocamento);
    int deslocamento = (stack->table->deslocamento) ? stack->table->deslocamento : 0;
    pop_table(&stack);

    // printf("\n ##>>>>>>Deslocamento: %d\n",stack->table->deslocamento);
    if(stack->table){
        // stack->table->deslocamento = deslocamento;
    }

};
/* ================== Tipo ============================== */
tipo: 
    TK_PR_INT {
        $$ = INT;
    }
    | TK_PR_FLOAT{
        $$ = FLOAT;
    };


/* ================== Programa ============================== */

programa: 
    lista_de_funcoes { 
        $$ = $1; 
        arvore = $$; 
        GRAPHVIZ_PRINT;
        // asd_print_graphviz(arvore); 
    } 
    | /* vazio */ { 
        $$ = NULL; 
        arvore = $$; 
        GRAPHVIZ_PRINT;
        // asd_print_graphviz(arvore); 
    };

lista_de_funcoes: 
    funcao desempilha_tabela lista_de_funcoes {
        $$ = $1; 
        asd_add_child($$,$3);
    }
    | funcao { $$ = $1;};


/* ================== Funcao ============================== */
funcao: cabecalho corpo { 
    $$ = $1;  
    ADD_CHILDREN_IF_NOT_NULL_MACRO($$,$2);
    // if($2 != NULL){asd_add_child($$,$2);} 
};

cabecalho: 
    TK_IDENTIFICADOR '=' empilha_tabela lista_de_parametros '>' tipo {

        $$ = asd_new($1->valor); 
        //[ACTION] : Criar macro para verificar_ERR_DECLARED
        Symbol *retorno = find_symbol(stack->next->table,$1->valor);
        if(retorno != NULL){
            printf("Erro na linha %d, funcao '%s' já declarada na linha %d\n",get_line_number(), $1->valor, retorno->linha);
            exit(ERR_DECLARED);
        } //assume pilha tem profundidade = 2 

        insert_symbol(stack->next->table,$$->label,get_line_number(),FUNCAO,$6);
        valor_lexico_free($1);
    }
    | TK_IDENTIFICADOR '=' empilha_tabela '>' tipo {
        $$ = asd_new($1->valor); 

        //[ACTION] : Criar macro para verificar_ERR_DECLARED
        Symbol *retorno = find_symbol(stack->next->table,$1->valor);
        if(retorno != NULL){
            printf("Erro na linha %d, funcao '%s' já declarada na linha %d\n",get_line_number(), $1->valor, retorno->linha);
            exit(ERR_DECLARED);
        }  //assume pilha tem profundidade = 2 

        insert_symbol(stack->next->table,$$->label,get_line_number(),FUNCAO,$5);
        valor_lexico_free($1);

    };
 
lista_de_parametros: 
    lista_de_parametros TK_OC_OR parametro { $$ = NULL; }
    | parametro { $$ = NULL; };

parametro: TK_IDENTIFICADOR '<' '-' tipo { 
        $$ = NULL;
        //[ACTION] : Criar macro para verificar_ERR_DECLARED
        Symbol *retorno;
        retorno = find_symbol(stack->table,$1->valor);
        if(retorno != NULL){
            printf("Erro na linha %d, parâmetro '%s' já declarado na linha %d\n",get_line_number(), $1->valor, retorno->linha);
            exit(ERR_DECLARED);
        } 
        insert_symbol(stack->table,$1->valor,get_line_number(),IDENTIFICADOR,$4);
    };


/* ================== Corpo ============================== */
corpo: bloco_comandos_Func { 
    $$ = $1; 
};

/* ============================== [3.2] Bloco de Comandos ============================== */
bloco_comandos_Func: 
    '{' '}' { $$ = NULL; }
    | '{' sequencia_de_comandos '}' { $$ = $2; };

bloco_comandos: 
    '{' '}' { $$ = NULL; }
    | '{' empilha_tabela sequencia_de_comandos desempilha_tabela '}' { 
        $$ = $3; 
    };

sequencia_de_comandos: 
    comando_simples ';' { 
        $$ = $1; 
    }
    | comando_simples ';' sequencia_de_comandos { 
        //[MAYBE][ACTION] : Criar macro para Acoes de Comandos
        $$ = ($1 != NULL) ? $1 : $3;
        if ($1 != NULL && $3 != NULL) {
            asd_add_child($$, $3);
        }
        
    } 
    | declaracao_variavel  ';' sequencia_de_comandos { 
        //[MAYBE][ACTION] : Criar macro para Acoes de Comandos
        $$ = ($1 != NULL) ? $1 : $3; 
        if ($1 != NULL && $3 != NULL) {
            asd_add_child(asd_get_last_child($$), $3);
        }
    }
    | declaracao_variavel  ';' { 
        $$ = $1; 
    };

/* ============================== [3.3] Comandos ============================== */
comando_simples: 
    bloco_comandos { $$ = $1; }
    | comando_atribuicao { $$ = $1; }
    | chamada_funcao { $$ = $1; }
    | comando_retorno { $$ = $1; }
    | comando_controle_fluxo { $$ = $1; };

/* ============================== [3.3.1] declaracao de variavel ==============================*/
declaracao_variavel: tipo lista_de_identificadores { 
    if($2 != NULL) {$2->tipo = $1;}
    $$ = $2; 
    set_symbol_type(stack->table, $1);
};



lista_de_identificadores: 
    identificador ',' lista_de_identificadores  {
        $$ = ($1 != NULL) ? $1 : $3;
        if ($1 != NULL && $3 != NULL) {asd_add_child($$, $3);}
    }

    | identificador { if($1 != NULL){$$ = $1;} }
;

identificador: 
    TK_IDENTIFICADOR { $$ = NULL; 
        Symbol *identificador = find_symbol(stack->table,$1->valor);

        if(identificador != NULL){
            printf("Erro na linha %d, identificador '%s' já declarado na linha %d\n",get_line_number(), $1->valor, identificador->linha);
            exit(ERR_DECLARED);
        }
        insert_symbol(stack->table,$1->valor,get_line_number(),IDENTIFICADOR,INDEFINIDO);
    }
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_FLOAT { 
        $$ = make_IDENTIFICADOR("<=",$1->valor,$3->valor);
        valor_lexico_free($1); valor_lexico_free($3);
    }
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_INT { 
        $$ = make_IDENTIFICADOR("<=",$1->valor,$3->valor);
        valor_lexico_free($1); valor_lexico_free($3);
    };
    


/* ============================== [3.3.2] comando de atribuicao ============================== */
comando_atribuicao: 
    TK_IDENTIFICADOR '=' expressao { 
        Symbol *symbol = find_symbol_in_stack(stack,$1->valor);
        if(symbol == NULL){
            printf("Erro na linha %d, variavel '%s' nao declarada\n",get_line_number(), $1->valor);
            exit(ERR_UNDECLARED);
        }
        if(symbol->natureza != IDENTIFICADOR) {
            printf("Erro na linha %d, variavel '%s' na verdade é uma funcao declarada na linha %d\n",get_line_number(), $1->valor,symbol->linha);
            exit(ERR_FUNCTION);
        }
        $$ = asd_new("=");
        asd_add_child($$, asd_new($1->valor)); 
        asd_add_child($$,$3); 
        valor_lexico_free($1);
        $$->tipo = symbol->tipo;
    };

/* ============================== [3.3.3] chamada de funcao ============================== */
chamada_funcao: TK_IDENTIFICADOR '(' lista_argumentos ')'
{ 
    Symbol *symbol = find_symbol_in_stack(stack,$1->valor);
    if(symbol == NULL){
        printf("Erro na linha %d, funcao '%s' nao declarada\n",get_line_number(), $1->valor);
        exit(ERR_UNDECLARED);
    }
    if(symbol->natureza != FUNCAO) {
        printf("Erro na linha %d, funcao '%s' na verdade é uma variavel declarada na linha %d\n",get_line_number(), $1->valor,symbol->linha);
        exit(ERR_VARIABLE);
    }

    $$ = asd_new(cria_label_func($1->valor));
    asd_add_child($$,$3); 
    valor_lexico_free($1);
};

lista_argumentos: 
    expressao ',' lista_argumentos { 
        $$ = $1; 
        asd_add_child($$, $3); 
    } 
    | expressao { $$ = $1; };

/* ============================== [3.3.4] comando de retorno ============================== */
comando_retorno: TK_PR_RETURN expressao { 
    $$ = asd_new("return"); 
    asd_add_child($$,$2); 
};

/* ============================== [3.3.5] comando de controle de fluxo ============================== */
comando_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos { 
        $$ = asd_new("if");
        ADD_CHILDREN_IF_NOT_NULL_MACRO($$,$3,$5);
        // asd_add_child($$,$3);
        // if($5 != NULL){asd_add_child($$,$5);}
    }
    | TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos { 
        $$ = asd_new("if");
        ADD_CHILDREN_IF_NOT_NULL_MACRO($$,$3,$5,$7);
    }
    | TK_PR_WHILE '(' expressao ')' bloco_comandos { 
        $$ = asd_new("while"); 
        ADD_CHILDREN_IF_NOT_NULL_MACRO($$,$3,$5);

        // asd_add_child($$,$3); 
        // if($5 != NULL){asd_add_child($$,$5);}
    };


/* ============================== EXPRESSOES ============================== */
expressao: expr_or { $$ = $1; };

expr_or: 
    expr_or TK_OC_OR expr_and {$$ = handle_binary_operation("|", $1, $3);  }
    | expr_and { $$ = $1; };

expr_and: 
    expr_and TK_OC_AND expr_eq { $$ = handle_binary_operation("&", $1, $3);  }
    | expr_eq { $$ = $1; };

expr_eq: 
    expr_eq TK_OC_NE expr_rel { $$ = handle_binary_operation("!=", $1, $3);  }
    | expr_eq TK_OC_EQ expr_rel { $$ = handle_binary_operation("==", $1, $3); }
    | expr_rel { $$ = $1; };


/* ============================== [3.4] Expressoes aritmeticas ============================== */
expr_rel:
    expr_rel '<' expr_add { $$ = handle_binary_operation("<", $1, $3); }
    | expr_rel '>' expr_add { $$ = handle_binary_operation(">", $1, $3); }
    | expr_rel TK_OC_LE expr_add { $$ = handle_binary_operation("<=", $1, $3); }
    | expr_rel TK_OC_GE expr_add { $$ = handle_binary_operation(">=", $1, $3); }
    | expr_add { $$ = $1; };

/* ============================== [3.4] Expressoes aritmeticas ============================== */
expr_add: 
    expr_add '+' expr_mult { $$ = handle_binary_operation("+", $1, $3); }
    | expr_add '-' expr_mult { $$ = handle_binary_operation("-", $1, $3); }
    | expr_mult { $$ = $1; };


expr_mult: 
    expr_mult '*' expr_unary { 
        $$ = handle_binary_operation("*", $1, $3); 
    }
    | expr_mult '/' expr_unary { 
        $$ = handle_binary_operation("/", $1, $3); 
    }
    | expr_mult '%' expr_unary { 
        $$ = handle_binary_operation("%", $1, $3); 
    }
    | expr_unary { 
        $$ = $1; 
    };


expr_unary: 
    '-' expr_unary { 
        $$ = asd_new_with_1_child("-",$2);
    }
    | '!' expr_unary { 
        $$ = asd_new_with_1_child("!",$2);
    }
    | primary { 
        $$ = $1; 
    };

primary: 

    /* Expressoes caso 2 
     * [MAYBE ACTION]: Criar macro para verificar se o identificador foi declarado
     */
    TK_LIT_FLOAT { 
        $$ = asd_new($1->valor); 
        valor_lexico_free($1); 
        $$->tipo = FLOAT;
    }
    | TK_LIT_INT { 
        $$ = asd_new($1->valor); 
        valor_lexico_free($1); 
        $$->tipo = INT;
    }
    | TK_IDENTIFICADOR { 
        char *temp = GeraTemp();
        #ifdef DVERBOSE
        printf("==================foo!\n");
        #endif

        $$ = handleAtribuicao(stack, $1);
    };
    | chamada_funcao  { 
        $$ = $1; 
    }
    | '(' expressao ')' {
        $$ = $2; 
    }
%%

/* ============================== Funcoes ================================== */

/* 
 * [Engehnaria de Software]
 * Funcao que lida com declaracao de variaveis
 * @param stack: pilha de tabelas de simbolos
 * @param vl: valor lexico
* @return asd_tree_t*: Nó da árvore sintática abstrata (AST)
 */
asd_tree_t *handleAtribuicao(void *stack, valor_lexico_t *vl) {
    if (!vl) {
        fprintf(stderr, "Erro interno: valor_lexico nulo em handleAtribuicao.\n");
        exit(EXIT_FAILURE);
    }

    Symbol *symbol = find_symbol_in_stack(stack, vl->valor);
    if (symbol == NULL) {
        printf("Erro na linha %d, variável '%s' não declarada\n", vl->linha, vl->valor);
        exit(ERR_UNDECLARED);
    }
    if (symbol->natureza != IDENTIFICADOR) {
        printf("Erro na linha %d, variável '%s' na verdade é uma função declarada na linha %d\n",vl->linha, vl->valor, symbol->linha);
        exit(ERR_FUNCTION);
    }

    asd_tree_t *node = asd_new(vl->valor);
    node->tipo = symbol->tipo;
    node->local = GeraTemp();

    char deslocamento_str[12]; 
    sprintf(deslocamento_str, "%d", symbol->deslocamento);
    node->codigo = geraCodigo("loadAI","rfp",deslocamento_str,node->local);

    /* printf("\n>>>>[DEBUG] \n");  
    imprimeIlocInstruction(node->codigo->instruction);

    printf("\n>>>>[DEBUG] \n");  
    imprimeListaIlocInstructions(node->codigo); */


    

    /* Implementado em valor_lexico.c */
    valor_lexico_free(vl);

    return node;
}

/* 
 * Esta função é chamada quando ocorre um erro de sintaxe (Bison default)
*/
void yyerror(char const *mensagem)
{
    fprintf(stderr, "%s on line %d\n", mensagem, get_line_number());
}

/* 
* Função que cria uma label para a chamada de uma função ( call <identificador> )
*/
char *cria_label_func(char *identificador)
{
    int tam = strlen("call ") + strlen(identificador) + 1;
    char *ret = (char *)malloc(tam * sizeof(char)); //char tem 1 byte mas não fazer a mult doi no coracao

    if (ret == NULL) {
        return NULL;
    }

    strcpy(ret, "call ");
    strcat(ret, identificador);

    return ret;
}
/*
* Função que cria uma árvore para um identificador
*/
asd_tree_t *make_IDENTIFICADOR(const char *label,const char *nome_identificador,const char *valor){
    asd_tree_t *new_identificador = asd_new(label); 
    
    asd_add_child(new_identificador, asd_new(nome_identificador));
    asd_add_child(new_identificador, asd_new(valor));

    Symbol *identificador = find_symbol(stack->table,nome_identificador);
    if(identificador != NULL){
        printf("Erro na linha %d, identificador '%s' já declarado na linha %d\n",get_line_number(), nome_identificador, identificador->linha);
        exit(ERR_DECLARED);
    }

    insert_symbol(stack->table,nome_identificador,get_line_number(),IDENTIFICADOR,INDEFINIDO);

    return new_identificador;
}

/* =========== FOO ======================

int main() { 
    int a ; 
    int b; 
    {
        int c;
        int d;
    }
    int e; 


#---------------
    ::  deslocamento :: Tamaho 
 a  ::      0        :: 4 
 b  ::      4        :: 4
 c  ::      8        :: 4
 d  ::      12       :: 4
 e  ::      16       :: 4



 */