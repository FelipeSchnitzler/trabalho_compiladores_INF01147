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
    char *cria_label_func(char *identificador);
    
%}

%code requires { 
    #include "asd.h" 
    #include "valor_lexico.h" 
    #include "table.h"
    #include "errors.h"
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
%type<arvore>  expr7
%type<arvore>  expr6
%type<arvore>  expr5
%type<arvore>  expr4
%type<arvore>  expr3
%type<arvore>  expr2
%type<arvore>  expr1
%type<tiposvar> tipo

%define parse.error verbose

%%
main: cria_escopo_global programa destroi_escopo_global;


/*============= TABLE ACTIONS ============================= */
cria_escopo_global:
{
    stack = create_stack();
    push_table(&stack);
};

destroi_escopo_global: 
{
    free_stack(stack);
};

empilha_tabela: 
{
    push_table(&stack);
};

desempilha_tabela: 
{
    pop_table(&stack);
};

/* ================== Programa ============================== */

programa: 
    lista_de_funcoes { $$ = $1; arvore = $$; asd_print_graphviz(arvore); } 
    | /* vazio */ { $$ = NULL; arvore = $$; asd_print_graphviz(arvore); };

lista_de_funcoes: 
    funcao desempilha_tabela lista_de_funcoes {$$ = $1; asd_add_child($$,$3); }
    | funcao { $$ = $1;};


/* ================== Tipo ============================== */
tipo: 
    TK_PR_INT {
        $$ = INT;
    }
    | TK_PR_FLOAT{
        $$ = FLOAT;
    };

/* ================== Funcao ============================== */
funcao: cabecalho corpo { 
    $$ = $1;  
    if($2 != NULL){asd_add_child($$,$2);} 
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
        asd_add_child($$,$3); valor_lexico_free($1);
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
        asd_add_child($$,$3);
        if($5 != NULL){asd_add_child($$,$5);}
    }
    | TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos { 
        $$ = asd_new("if");
        ADD_CHILDREN_IF_NOT_NULL_MACRO($$,$3,$5,$7);
    }
    | TK_PR_WHILE '(' expressao ')' bloco_comandos { 
        $$ = asd_new("while"); 
        asd_add_child($$,$3); 
        if($5 != NULL){asd_add_child($$,$5);}
    };


/* ============================== EXPRESSOES ============================== */
expressao: expr7 { $$ = $1; };

expr7: 
    expr7 TK_OC_OR expr6 {$$ = handle_binary_operation("|", $1, $3);  }
    | expr6 { $$ = $1; };

expr6: 
    expr6 TK_OC_AND expr5 { $$ = handle_binary_operation("&", $1, $3);  }
    | expr5 { $$ = $1; };

expr5: 
    expr5 TK_OC_NE expr4 { $$ = handle_binary_operation("!=", $1, $3);  }
    | expr5 TK_OC_EQ expr4 { $$ = handle_binary_operation("==", $1, $3); }
    | expr4 { $$ = $1; };


/* ============================== [3.4] Expressoes aritmeticas ============================== */
expr4:
    expr4 '<' expr3 { $$ = handle_binary_operation("<", $1, $3); }
    | expr4 '>' expr3 { $$ = handle_binary_operation(">", $1, $3); }
    | expr4 TK_OC_LE expr3 { $$ = handle_binary_operation("<=", $1, $3); }
    | expr4 TK_OC_GE expr3 { $$ = handle_binary_operation(">=", $1, $3); }
    | expr3 { $$ = $1; };

/* ============================== [3.4] Expressoes aritmeticas ============================== */
expr3: 
    expr3 '+' expr2 { $$ = handle_binary_operation("+", $1, $3); }
    | expr3 '-' expr2 { $$ = handle_binary_operation("-", $1, $3); }
    | expr2 { $$ = $1; };


expr2: 
    expr2 '*' expr1 { 
        $$ = handle_binary_operation("*", $1, $3); 
    }
    | expr2 '/' expr1 { 
        $$ = handle_binary_operation("/", $1, $3); 
    }
    | expr2 '%' expr1 { 
        $$ = handle_binary_operation("%", $1, $3); 
    }
    | expr1 { 
        $$ = $1; 
    };


expr1: 
    '-' expr1 { 
        $$ = asd_new_with_1_child("-",$2);
    }
    | '!' expr1 { 
        $$ = asd_new_with_1_child("!",$2);
    }
    | chamada_funcao  { 
        $$ = $1; 
    }
    | '(' expressao ')' {
        $$ = $2; 
    }
    /* Expressoes caso 2 
     * [MAYBE ACTION]: Criar macro para verificar se o identificador foi declarado
     */
    | TK_LIT_FLOAT { 
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
        Symbol *symbol = find_symbol_in_stack(stack,$1->valor);
        if(symbol == NULL){
            printf("Erro na linha %d, variavel '%s' nao declarada\n",get_line_number(), $1->valor);
            exit(ERR_UNDECLARED);
        }
        if(symbol->natureza != IDENTIFICADOR) {
            printf("Erro na linha %d, variavel '%s' na verdade é uma funcao declarada na linha %d\n",get_line_number(), $1->valor,symbol->linha);
            exit(ERR_FUNCTION);
        }

        $$ = asd_new($1->valor); 
        $$->tipo = symbol->tipo;
        valor_lexico_free($1); 
    };
%%

void yyerror(char const *mensagem)
{
    fprintf(stderr, "%s on line %d\n", mensagem, get_line_number());
}

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