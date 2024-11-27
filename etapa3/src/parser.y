%{
    #include <string.h>
    #include <stdio.h>
    int yylex(void);
    void yyerror (char const *mensagem);
    int get_line_number();
    extern void *arvore;
    char *cria_label_func(char *identificador);
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

%type<arvore> 
    programa
    lista_de_funcoes
    funcao
    cabecalho
    lista_de_parametros
    parametro
    corpo
    bloco_comandos
    sequencia_de_comandos
    comando_simples
    declaracao_variavel
    lista_de_identificadores
    identificador
    comando_atribuicao
    chamada_funcao
    lista_argumentos
    comando_retorno
    comando_controle_fluxo
    expressao
    expr7
    expr6
    expr5
    expr4
    expr3
    expr2
    expr1

%define parse.error verbose

%%

programa: 
    lista_de_funcoes { $$ = $1; arvore = $$; asd_print_graphviz(arvore); } 
    | /* vazio */ { $$ = NULL; arvore = $$; };

lista_de_funcoes: 
    funcao lista_de_funcoes {$$ = $1; asd_add_child($$,$2); }
    | funcao { $$ = $1; };

// utils
tipo: TK_PR_INT | TK_PR_FLOAT; //Nao importa pq sempre é ignorado mais na frente

//funcao
funcao: cabecalho corpo { $$ = $1;  if($2 != NULL){asd_add_child($$,$2);} };

cabecalho: 
    TK_IDENTIFICADOR '=' lista_de_parametros '>' tipo {$$ = asd_new($1->valor); valor_lexico_free($1);}
    | TK_IDENTIFICADOR '=' '>' tipo {$$ = asd_new($1->valor); valor_lexico_free($1); };
 
lista_de_parametros: 
    lista_de_parametros TK_OC_OR parametro { $$ = NULL; }
    | parametro { $$ = NULL; };

parametro: TK_IDENTIFICADOR '<' '-' tipo { $$ = NULL; };

corpo: bloco_comandos { $$ = $1; };

/* ============================== [3.2] ============================== */
bloco_comandos: '{' '}' { $$ = NULL; }| 
                '{' sequencia_de_comandos '}' { $$ = $2; };

/* ACHO QUE EH AQUI QUE ESTA O PROBLEMA DO TESTE E3/z07 */
sequencia_de_comandos: 
    comando_simples ';' { $$ = $1; }
    | comando_simples ';' sequencia_de_comandos { 
        $$ = $1;  
        if($$ != NULL)
        { if($3 != NULL) { asd_add_child($$,$3); } 
        
        }
            else{  if($3 != NULL) { $$ = $3;} else  {$$ = NULL;} 
        } 
    }; 

/* ============================== [3.3] Comandos ============================== */
comando_simples: 
    bloco_comandos { $$ = $1; }
    | declaracao_variavel { $$ = $1; }
    | comando_atribuicao { $$ = $1; }
    | chamada_funcao { $$ = $1; }
    | comando_retorno { $$ = $1; }
    | comando_controle_fluxo { $$ = $1; };

/* ============================== [3.3.1] declaracao de variavel ==============================*/
declaracao_variavel: tipo lista_de_identificadores { $$ = $2; };



lista_de_identificadores: 
    identificador ',' lista_de_identificadores  {
        $$ = ($1 != NULL) ? $1 : $3;
        if ($1 != NULL) asd_add_child($$, $3);
    }

    | identificador { if($1 != NULL){$$ = $1;} }
;

/* ============ [OLD] ========================= */
/* lista_de_identificadores: 
    identificador { if($1 != NULL){$$ = $1;} }
    | identificador ',' lista_de_identificadores 
{ //THIS LOOKS WRONG AS THE SUN RISING IN THE WEST
    if($1 != NULL)
    { 
        $$ = $1; 
        if($3 != NULL)
        {
            asd_add_child($$,$3);
        }
    }else if($3 != NULL)
    {
        $$ = $3;
    }else
    {
        $$ = NULL;
    }
}; */
/* ============ [OLD] ========================= */

identificador: 
    TK_IDENTIFICADOR { $$ = NULL; }
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_FLOAT { 
            $$ = asd_new("<="); 
            asd_add_child($$, asd_new($1->valor));
            asd_add_child($$, asd_new($3->valor));
            valor_lexico_free($1); valor_lexico_free($3);}
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_INT { 
            $$ = asd_new("<="); 
            asd_add_child($$, asd_new($1->valor)); 
            asd_add_child($$, asd_new($3->valor));
            valor_lexico_free($1); valor_lexico_free($3);
    };
    


/* ============================== [3.3.2] comando de atribuicao ============================== */
comando_atribuicao: 
    TK_IDENTIFICADOR '=' expressao { 
            $$ = asd_new("=");
            asd_add_child($$, asd_new($1->valor)); 
            asd_add_child($$,$3); valor_lexico_free($1);
    };

/* ============================== [3.3.3] chamada de funcao ============================== */
chamada_funcao: TK_IDENTIFICADOR '(' lista_argumentos ')'{ $$ = asd_new(cria_label_func($1->valor)); asd_add_child($$,$3); valor_lexico_free($1);};

lista_argumentos: 
    expressao ',' lista_argumentos { $$ = $1; asd_add_child($$, $3); } 
    | expressao { $$ = $1; };

/* ============================== [3.3.4] comando de retorno ============================== */
comando_retorno: TK_PR_RETURN expressao { $$ = asd_new("return"); asd_add_child($$,$2); };

/* ============================== [3.3.5] comando de controle de fluxo ============================== */
comando_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos { $$ = asd_new("if"); asd_add_child($$,$3); if($5 != NULL){asd_add_child($$,$5);}}
    | TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos { $$ = asd_new("if"); asd_add_child($$,$3); if($5 != NULL){asd_add_child($$,$5);} if($7 != NULL){asd_add_child($$,$7);}}
    | TK_PR_WHILE '(' expressao ')' bloco_comandos { $$ = asd_new("while"); asd_add_child($$,$3); if($5 != NULL){asd_add_child($$,$5);}};


/* ============================== EXPRESSOES ============================== */
expressao: expr7 { $$ = $1; };

expr7: 
    expr7 TK_OC_OR expr6 {$$ = asd_new("|"); asd_add_child($$,$1); asd_add_child($$,$3);}
    | expr6 { $$ = $1; };

expr6: 
    expr6 TK_OC_AND expr5 { $$ = asd_new("&"); asd_add_child($$,$1); asd_add_child($$,$3); }
    | expr5 { $$ = $1; };

expr5: 
    expr5 TK_OC_NE expr4 { $$ = asd_new("!="); asd_add_child($$,$1); asd_add_child($$,$3); }
    | expr5 TK_OC_EQ expr4 { $$ = asd_new("=="); asd_add_child($$,$1); asd_add_child($$,$3); }
    | expr4 { $$ = $1; };

expr4: 
    expr4 '<' expr3 { $$ = asd_new("<"); asd_add_child($$,$1); asd_add_child($$,$3); }
    | expr4 '>' expr3 { $$ = asd_new(">"); asd_add_child($$,$1); asd_add_child($$,$3); }
    | expr4 TK_OC_LE expr3 { $$ = asd_new("<="); asd_add_child($$,$1); asd_add_child($$,$3); }
    | expr4 TK_OC_GE expr3 { $$ = asd_new(">="); asd_add_child($$,$1); asd_add_child($$,$3); }
    | expr3 { $$ = $1; };

expr3: 
expr3 '+' expr2 { $$ = asd_new("+"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr3 '-' expr2 { $$ = asd_new("-"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr2 { $$ = $1; };

expr2: 
expr2 '*' expr1 { $$ = asd_new("*"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr2 '/' expr1 { $$ = asd_new("/"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr2 '%' expr1 { $$ = asd_new("%"); asd_add_child($$,$1); asd_add_child($$,$3); }
| expr1 { $$ = $1;};

expr1: 
'-' expr1 { $$ = asd_new("-"); asd_add_child($$,$2); }
| '!' expr1 { $$ = asd_new("!"); asd_add_child($$,$2); }
| TK_IDENTIFICADOR { $$ = asd_new($1->valor); valor_lexico_free($1); }
| TK_LIT_FLOAT { $$ = asd_new($1->valor); valor_lexico_free($1); }
| TK_LIT_INT { $$ = asd_new($1->valor); valor_lexico_free($1); }
| chamada_funcao  { $$ = $1; }
|'(' expressao ')' { $$ = $2; };

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
