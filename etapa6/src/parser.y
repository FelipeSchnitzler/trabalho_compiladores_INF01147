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

    asd_tree_t *handleLiteral (valor_lexico_t *vl, TipoDado tipo);
    asd_tree_t *handleAtribuicao(void *stack, valor_lexico_t *vl);
    asd_tree_t *handleUnaryOperation(char *op, asd_tree_t *expr);
    asd_tree_t* handle_arithmetic(const char* operator, asd_tree_t* left, asd_tree_t* right);
    asd_tree_t* handle_relop (const char* operator, asd_tree_t* left, asd_tree_t* right);


    /* Macros */
    #if defined(_DEBUG_)        
        #define GRAPHVIZ_PRINT asd_print_graphviz(arvore);
        #define PRINT_DEBUG printf("DEBUG: %s:%d\n",__FILE__,__LINE__);
        #define PRINT_CODE  imprimeListaIlocInstructions(node->codigo);
        #define PRINT_PILHA print_stack(stack);
        #define PRINT_SEPARATOR printf("=================================================\n"); 
        // #define GRAPHVIZ_PRINT 1 // Não faz nada
    #else
        #define GRAPHVIZ_PRINT // Não faz nada
        #define PRINT_DEBUG // Não faz nada
        #define PRINT_CODE // Não faz nada
        #define PRINT_PILHA // Não faz nada
        #define PRINT_SEPARATOR // Não faz nada
    #endif
    #define PRINT_TREE asd_print_graphviz(arvore);
    #if defined(PRINT_TREE)
        #define PRINT_TREE asd_print_graphviz(arvore);
    #else
        #define PRINT_TREE // Não faz nada
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
};

destroi_escopo_global: 
{
    // PRINT_PILHA;
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

};

desempilha_tabela: 
{
    PRINT_PILHA;
    int deslocamento = (stack->table->deslocamento) ? stack->table->deslocamento : 0;
    pop_table(&stack);

    if(stack->table){
        stack->table->deslocamento = deslocamento;
    };

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
        // GRAPHVIZ_PRINT;
        // PRINT_TREE
        //  asd_print_graphviz(arvore); 
    } 
    | /* vazio */ { 
        $$ = NULL; 
        arvore = $$; 
        // PRINT_TREE
        // asd_print_graphviz(arvore); 
    };

lista_de_funcoes: 
    funcao desempilha_tabela lista_de_funcoes {
        $$ = $1; 
        asd_add_child($$,$3);
        $$->codigo = concatenaInstrucoes($1->codigo, $3->codigo);
    }
    | funcao { 
        $$ = $1;
    };


/* ================== Funcao ============================== */
funcao: cabecalho corpo { 
    $$ = $1;  
    if($2 != NULL){
        asd_add_child($$,$2);
        $$->codigo = $2->codigo; 
    }
};

cabecalho: 
    TK_IDENTIFICADOR '=' empilha_tabela lista_de_parametros '>' tipo {

        $$ = asd_new($1->valor); 
        //[ACTION] : Criar macro para verificar_ERR_DECLARED
        Symbol *retorno = find_symbol(stack->next->table,$1->valor);
        //assume pilha tem profundidade = 2
        if(retorno != NULL){
            printf("Erro na linha %d, funcao '%s' já declarada na linha %d\n",get_line_number(), $1->valor, retorno->linha);
            exit(ERR_DECLARED);
        }  

        insert_symbol(stack->next->table,$$->label,get_line_number(),FUNCAO,$6);
        valor_lexico_free($1);
    }
    | TK_IDENTIFICADOR '=' empilha_tabela '>' tipo {
        $$ = asd_new($1->valor); 

        //assume pilha tem profundidade = 2 
        //[ACTION] : Criar macro para verificar_ERR_DECLARED
        Symbol *retorno = find_symbol(stack->next->table,$1->valor);
        if(retorno != NULL){
            printf("Erro na linha %d, funcao '%s' já declarada na linha %d\n",get_line_number(), $1->valor, retorno->linha);
            exit(ERR_DECLARED);
        }  

        insert_symbol(stack->next->table,$$->label,get_line_number(),FUNCAO,$5);
        valor_lexico_free($1);

    };
 
lista_de_parametros: 
    lista_de_parametros TK_OC_OR parametro { 
        $$ = NULL; 
    }
    | parametro { 
        $$ = NULL; 
    };

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
    '{' '}' { 
        $$ = NULL; 
    }
    | '{' sequencia_de_comandos '}' { 
        $$ = $2; 
    };

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
            $$->codigo = concatenaInstrucoes($$->codigo, $3->codigo);
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
    bloco_comandos { 
        $$ = $1; 
    }
    | comando_atribuicao { 
        $$ = $1; 
    }
    | chamada_funcao { 
        $$ = $1; 
    }
    | comando_retorno { 
        $$ = $1; 
    }
    | comando_controle_fluxo { 
        $$ = $1; 
    };

/* ============================== [3.3.1] declaracao de variavel ==============================*/
declaracao_variavel: tipo lista_de_identificadores { 
    if($2 != NULL) {$2->tipo = $1;}
    $$ = $2; 
    set_symbol_type(stack->table, $1);
};



lista_de_identificadores: 
    identificador ',' lista_de_identificadores  {
        $$ = ($1 != NULL) ? $1 : $3;
        if ($1 != NULL && $3 != NULL) {
            asd_add_child($$, $3);
        }
    }

    | identificador { if($1 != NULL){
        $$ = $1;
        } 
    }
;

identificador: 
    TK_IDENTIFICADOR { 
        $$ = NULL; 
        Symbol *identificador = find_symbol(stack->table,$1->valor);

        if(identificador != NULL){
            printf("Erro na linha %d, identificador '%s' já declarado na linha %d\n",get_line_number(), $1->valor, identificador->linha);
            exit(ERR_DECLARED);
        }
        insert_symbol(stack->table,$1->valor,get_line_number(),IDENTIFICADOR,INDEFINIDO);
        
    }
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_FLOAT { 
        $$ = make_IDENTIFICADOR("<=",$1->valor,$3->valor);
        valor_lexico_free($1); 
        valor_lexico_free($3);
    }
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_INT { 
        $$ = make_IDENTIFICADOR("<=",$1->valor,$3->valor);
        valor_lexico_free($1); 
        valor_lexico_free($3);
    };
    


/* ============================== [3.3.2] comando de atribuicao ============================== */
comando_atribuicao: 
    TK_IDENTIFICADOR '=' expressao { 

        /*[Macro]: Handle symbol search --------------------------------------------------------------------- */
        Symbol *symbol = find_symbol_in_stack(stack,$1->valor);
        if(symbol == NULL){
            printf("Erro na linha %d, variavel '%s' nao declarada\n",get_line_number(), $1->valor);
            exit(ERR_UNDECLARED);
        }
        
        if(symbol->natureza != IDENTIFICADOR) {
            printf("Erro na linha %d, variavel '%s' na verdade é uma funcao declarada na linha %d\n",get_line_number(), $1->valor,symbol->linha);
            exit(ERR_FUNCTION);
        }
        /*[Macro]: fim ----------------------------------------------------------------------------------------*/ 
           
        $$ = asd_new("=");
        asd_add_child($$, asd_new($1->valor)); 
        asd_add_child($$,$3); 

        /* [Revisar] : criar func ou macro  */ 
        valor_lexico_free($1);
        $$->tipo = symbol->tipo;

        /* ============================== [ILOC] ============================== */  
        char deslocamento_str[12]; 
        sprintf(deslocamento_str, "%d", symbol->deslocamento);
        
        IlocList_t* tempCode = criaInstrucao("storeAI", $3->local , "rfp", deslocamento_str);        
        $$->codigo = concatenaInstrucoes($3->codigo, tempCode);

        

      
    };

/* ============================== [3.3.3] chamada de funcao ============================== */
chamada_funcao: TK_IDENTIFICADOR '(' lista_argumentos ')'
{ 
    /*[Macro]: Handle symbol search --------------------------------------------------------------------- */
    Symbol *symbol = find_symbol_in_stack(stack,$1->valor);
    if(symbol == NULL){
        printf("Erro na linha %d, funcao '%s' nao declarada\n",get_line_number(), $1->valor);
        exit(ERR_UNDECLARED);
    }
    if(symbol->natureza != FUNCAO) {
        printf("Erro na linha %d, funcao '%s' na verdade é uma variavel declarada na linha %d\n",get_line_number(), $1->valor,symbol->linha);
        exit(ERR_VARIABLE);
    }

    /*[Macro]: fim ----------------------------------------------------------------------------------------*/ 

    $$ = asd_new(cria_label_func($1->valor));
    
    asd_add_child($$,$3); 
    valor_lexico_free($1);
};

lista_argumentos: 
    expressao ',' lista_argumentos { 
        $$ = $1; 
        asd_add_child($$, $3); 
        $$->codigo = concatenaInstrucoes($1->codigo, $3->codigo);
    } 
    | expressao { 
        $$ = $1; 
    };

/* ============================== [3.3.4] comando de retorno ============================== */
comando_retorno: TK_PR_RETURN expressao { 
    $$ = asd_new("return"); 
    asd_add_child($$,$2); 
    $$->codigo = $2->codigo;
};

/* ============================== [3.3.5] comando de controle de fluxo ============================== */
comando_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos { 
        $$ = asd_new("if");
        ADD_CHILDREN_IF_NOT_NULL_MACRO($$, $3, $5);

        /* ============ [ILOC] ========================== */         
        char *label_true = GeraLabel(); 
        char *label_false = GeraLabel();
       
        IlocList_t* tempCode = criaInstrucao("cbr", $3->local, label_true, label_false);

        IlocList_t* trueLabel = criaInstrucao(label_true, ": nop", NULL, NULL);
        IlocList_t* falseLabel = criaInstrucao(label_false, ": nop", NULL, NULL);

        $$->codigo = concatenaInstrucoes($3->codigo,              
                        concatenaInstrucoes(tempCode,            
                        concatenaInstrucoes(trueLabel,          
                        concatenaInstrucoes($5->codigo,         
                        falseLabel))));                         

    }
    | TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos { 
        $$ = asd_new("if");
        ADD_CHILDREN_IF_NOT_NULL_MACRO($$,$3,$5,$7);

        /* ILOC */
        char *label_true = GeraLabel();  
        char *label_false = GeraLabel(); 
        char *label_end = GeraLabel();   
     
        IlocList_t* cbrCode = criaInstrucao("cbr", $3->local, label_true, label_false);

        IlocList_t* instruct_trueLabel = criaInstrucao(label_true, ": nop", NULL, NULL);
        IlocList_t* instruct_falseLabel = criaInstrucao(label_false, ": nop", NULL, NULL);
        IlocList_t* jumpToEnd = criaInstrucao("jumpI", label_end, NULL, NULL);
        IlocList_t* instruct_endLabel = criaInstrucao(label_end, ": nop", NULL, NULL);

        $$->codigo = concatenaInstrucoes($3->codigo,       
                     concatenaInstrucoes(cbrCode,          
                     concatenaInstrucoes(instruct_trueLabel,        
                     concatenaInstrucoes($5->codigo,       
                     concatenaInstrucoes(jumpToEnd,        
                     concatenaInstrucoes(instruct_falseLabel,       
                     concatenaInstrucoes($7->codigo,       
                     instruct_endLabel)))))));                      
        
    }
    | TK_PR_WHILE '(' expressao ')' bloco_comandos { 
        $$ = asd_new("while"); 
        ADD_CHILDREN_IF_NOT_NULL_MACRO($$,$3,$5);

        /* ============================== [ILOC] ============================== */
        char *label_start = GeraLabel();
        char *label_true = GeraLabel();
        char *label_false = GeraLabel();

        IlocList_t* startLabel = criaInstrucao(label_start, ": nop", NULL, NULL);
        IlocList_t* cbrCode = criaInstrucao("cbr", $3->local, label_true, label_false);
        IlocList_t* trueLabel = criaInstrucao(label_true, ": nop", NULL, NULL);
        IlocList_t* falseLabel = criaInstrucao(label_false, ": nop", NULL, NULL);
        IlocList_t* jumpToStart = criaInstrucao("jumpI", label_start, NULL, NULL);

        $$->codigo = concatenaInstrucoes(startLabel, 
                     concatenaInstrucoes($3->codigo,
                     concatenaInstrucoes(cbrCode, 
                     concatenaInstrucoes(trueLabel, 
                     concatenaInstrucoes($5->codigo, 
                     concatenaInstrucoes(jumpToStart, 
                     falseLabel))))));

    };


/* ============================== EXPRESSOES ============================== */
expressao: 
    expr_or {
        $$ = $1; 
    };

expr_or: 
    expr_or TK_OC_OR expr_and {$$ = handle_relop("|", $1, $3);  }
    | expr_and { $$ = $1; };

expr_and: 
    expr_and TK_OC_AND expr_eq { $$ = handle_relop("&", $1, $3);  }
    | expr_eq { $$ = $1; };

expr_eq: 
    expr_eq TK_OC_NE expr_rel { $$ = handle_relop("!=", $1, $3);  }
    | expr_eq TK_OC_EQ expr_rel { $$ = handle_relop("==", $1, $3); }
    | expr_rel { $$ = $1; };


/* ============================== [3.4] Expressoes aritmeticas ============================== */
expr_rel:
    expr_rel '<' expr_add { $$ = handle_relop("<", $1, $3); }
    | expr_rel '>' expr_add { $$ = handle_relop(">", $1, $3); }
    | expr_rel TK_OC_LE expr_add { $$ = handle_relop("<=", $1, $3); }
    | expr_rel TK_OC_GE expr_add { $$ = handle_relop(">=", $1, $3); }
    | expr_add { $$ = $1; };

/* ============================== [3.4] Expressoes aritmeticas ============================== */
expr_add: 
    expr_add '+' expr_mult { $$ = handle_arithmetic("+", $1, $3); }
    | expr_add '-' expr_mult { $$ = handle_arithmetic("-", $1, $3); }
    | expr_mult { $$ = $1; };


expr_mult: 
    expr_mult '*' expr_unary { 
        // $$ = handle_binary_operation("*", $1, $3); 
        $$ = handle_arithmetic("*", $1, $3);
    }
    | expr_mult '/' expr_unary { 
        $$ = handle_arithmetic("/", $1, $3); 
    }
    | expr_mult '%' expr_unary { 
        $$ = handle_arithmetic("%", $1, $3); 
    }
    | expr_unary { 
        $$ = $1; 
    };


expr_unary: 
    '-' expr_unary { 
        // $$ = asd_new_with_1_child("-",$2);
        $$ = handleUnaryOperation("-", $2);
    }
    | '!' expr_unary { 
        // $$ = asd_new_with_1_child("!", $2);
        $$ = handleUnaryOperation("!", $2);
    }
    | primary { 
        $$ = $1; 
    };

primary: 

    /* Expressoes caso 2 
     * [MAYBE ACTION]: Criar macro para verificar se o identificador foi declarado
     */
    TK_LIT_FLOAT { 
        $$ = handleLiteral($1, FLOAT);
    }
    | TK_LIT_INT { 
        $$ = handleLiteral($1, FLOAT);
    }
    | TK_IDENTIFICADOR { 
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


asd_tree_t* handle_relop (const char* operator, asd_tree_t* left, asd_tree_t* right) {
    asd_tree_t* node = handle_binary_operation(operator, left, right);
    
    if (!node) {
        printf("Erro em %s: falha ao criar nó para operador relacional.\n", __FUNCTION__);
        return NULL;
    }

    node->local = GeraTemp(); 
    IlocList_t* tempCode = NULL;

    if (strcmp(operator, "<") == 0) {
        tempCode = criaInstrucao("cmp_LT", left->local, right->local, node->local);
    } else if (strcmp(operator, ">") == 0) {
        tempCode = criaInstrucao("cmp_GT", left->local, right->local, node->local);
    } else if (strcmp(operator, "<=") == 0) {
        tempCode = criaInstrucao("cmp_LE", left->local, right->local, node->local);
    } else if (strcmp(operator, ">=") == 0) {
        tempCode = criaInstrucao("cmp_GE", left->local, right->local, node->local);
    } else if (strcmp(operator, "==") == 0) {
        tempCode = criaInstrucao("cmp_EQ", left->local, right->local, node->local);
    } else if (strcmp(operator, "!=") == 0) {
        tempCode = criaInstrucao("cmp_NE", left->local, right->local, node->local);
    }else if (strcmp(operator, "&") == 0) {
        PRINT_SEPARATOR
        PRINT_DEBUG
        tempCode = criaInstrucao("and", left->local, right->local, node->local);
        /* imprimeIlocInstruction(tempCode);   */
        PRINT_SEPARATOR
    } else if (strcmp(operator,  "|") == 0) {
        tempCode = criaInstrucao("or", left->local, right->local, node->local);
    } 
    else {
        fprintf(stderr, "Erro interno: operador relacional inválido '%s' em handle_relop.\n", operator);
        exit(EXIT_FAILURE);
    }

    node->codigo = concatenaInstrucoes(left->codigo, concatenaInstrucoes(right->codigo, tempCode));


    /* PRINT_SEPARATOR
    PRINT_CODE
    PRINT_SEPARATOR */

    return node;

}

 asd_tree_t* handle_arithmetic(const char* operator, asd_tree_t* left, asd_tree_t* right) {
    asd_tree_t* node = handle_binary_operation(operator, left, right);
    
    if (!node) {
        printf("Erro em %s: falha ao criar nó para operador relacional.\n", __FUNCTION__);
        return NULL;
    }

    node->local = GeraTemp(); 

    IlocList_t* tempCode = NULL;

    if (strcmp(operator, "+") == 0) {
        // Código para soma
        IlocList_t* add = criaInstrucao("add", left->local, right->local, node->local);
        tempCode = concatenaInstrucoes(left->codigo, concatenaInstrucoes(right->codigo, add));
    } 
    else if (strcmp(operator, "-") == 0) {
        // Código para subtração
        IlocList_t* sub = criaInstrucao("sub", left->local, right->local, node->local);
        tempCode = concatenaInstrucoes(left->codigo, concatenaInstrucoes(right->codigo, sub));
    } 
    else if (strcmp(operator, "*") == 0) {
        // Código para multiplicação
        IlocList_t* mul = criaInstrucao("mul", left->local, right->local, node->local);
        tempCode = concatenaInstrucoes(left->codigo, concatenaInstrucoes(right->codigo, mul));
    } 
    else if (strcmp(operator, "/") == 0) {
        // Código para divisão
        IlocList_t* div = criaInstrucao("div", left->local, right->local, node->local);
        tempCode = concatenaInstrucoes(left->codigo, concatenaInstrucoes(right->codigo, div));
    } 
    else if (strcmp(operator, "%") == 0) {
        // Código para módulo
        IlocList_t* mod = criaInstrucao("mod", left->local, right->local, node->local);
        tempCode = concatenaInstrucoes(left->codigo, concatenaInstrucoes(right->codigo, mod));
    } 
    else {
        fprintf(stderr, "Erro interno: operação inválida '%s' em handle_binary_operation.\n", operator);
        exit(EXIT_FAILURE);
    }

   
    node->codigo = tempCode;
    /* PRINT_CODE; */

    return node;
}

asd_tree_t *handleUnaryOperation(char *op, asd_tree_t *expr) {
    asd_tree_t *node = asd_new_with_1_child(op, expr);

    node->local = GeraTemp();
    if (strcmp(op, "-") == 0) {
        node->codigo = criaInstrucao("rsubI", "0", expr->local, node->local);
    } else if (strcmp(op, "!") == 0) {
        char *tempZero = GeraTemp();
        IlocList_t *loadZero = criaInstrucao("loadI", "0", NULL, tempZero);
        IlocList_t *cmp = criaInstrucao("cmp_EQ", expr->local, tempZero, node->local);
        node->codigo = concatenaInstrucoes(expr->codigo, concatenaInstrucoes(loadZero, cmp));
    } else {
        fprintf(stderr, "Erro interno: operação inválida '%s' em handleUnaryOperation.\n", op);
        exit(EXIT_FAILURE);
    }

    PRINT_CODE;


    return node;
}


/*
 * [Engehnaria de Software]
 * Funcao que lida com literais E -> TK_LIT_INT | TK_LIT_FLOAT
 */

asd_tree_t *handleLiteral (valor_lexico_t *vl, TipoDado tipo) {
        if (!vl) {
        fprintf(stderr, "Erro interno: valor_lexico nulo em handleAtribuicao.\n");
        exit(EXIT_FAILURE);
    }
    asd_tree_t *node = asd_new(vl->valor);
    node->tipo = tipo;
    node->local = GeraTemp();
    node->codigo = criaInstrucao("loadI", vl->valor, "", node->local);
   
    #ifdef DVERBOSE
        imprimeListaIlocInstructions(node->codigo);
    #endif
   
    return node;
}



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
    node->codigo = criaInstrucao("loadAI","rfp",deslocamento_str, node->local);
    

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