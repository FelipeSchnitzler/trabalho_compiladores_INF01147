# Compiladores 

## To Do 

- [ ] #define TRUE COMP $_ 0
- [ ] #define FALSE COMP $_ 0 
- [ ] Criar deslocamento Tabela de simbolos
- [ ] Alterar gramatica para receber

- [ ] `base, desloc = consulta(nome);`
- [ ]  
- [ ] 
- [ ] 
- [ ]  
Functions 
- [ ] GeraTemp();
- [ ] GeraLabel();
- [ ] Concatena();
- [ ] GetDesloc();
- [ ] cria_instrucao();

```c
typedef struct { 
    lista_instr_t *lista;
    temp_t *temporario;
} retorno_engsoft_t;

retorno_eng_soft_t gera_codigo_de_expressoes_binarias
( char *mneu, asd_tree_t f1, asd_tree_t )
{
    retorno_eng_soft_t  retorno = {0};
    temp_t = temporario = geratemp();
    iloc_t inst_mult = cria_instrucao("mult", f1.local, f2.local, temporario);
    retorno.codigo = concatena3(f1.codigo, f2.codigo, instr_mult);
    retorno.local = temporario;
};

```


## Gramática

```yacc
programa: 
    lista_de_funcoes
    | /* vazio */

lista_de_funcoes: 
    funcao desempilha_tabela lista_de_funcoes
    | funcao

tipo: 
    TK_PR_INT 
    | TK_PR_FLOAT

funcao: 
    cabecalho corpo ;

cabecalho: 
    TK_IDENTIFICADOR '=' empilha_tabela lista_de_parametros '>' tipo 
    | TK_IDENTIFICADOR '=' empilha_tabela '>' tipo ;

lista_de_parametros: 
    lista_de_parametros TK_OC_OR parametro
    | parametro

parametro: 
    TK_IDENTIFICADOR '<' '-' tipo ;

corpo: bloco_comandos_Func

bloco_comandos_Func: 
    '{' '}' { $$ = NULL; }
    | '{' sequencia_de_comandos '}'

bloco_comandos: 
    '{' '}' 
    |'{' empilha_tabela sequencia_de_comandos desempilha_tabela '}' { $$ = $3; };

sequencia_de_comandos: 
    comando_simples ';' 
    | comando_simples ';' sequencia_de_comandos
    | declaracao_variavel  ';' sequencia_de_comandos 
    | declaracao_variavel  ';' 

comando_simples: 
    bloco_comandos
    | comando_atribuicao
    | chamada_funcao
    | comando_retorno
    | comando_controle_fluxo

declaracao_variavel:  
    tipo lista_de_identificadores 

lista_de_identificadores: 
    identificador ',' lista_de_identificadores
    | identificador ;

identificador: 
    TK_IDENTIFICADOR 
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_FLOAT 
    | TK_IDENTIFICADOR TK_OC_LE TK_LIT_INT ;    


comando_atribuicao: 
    TK_IDENTIFICADOR '=' expressao ;

chamada_funcao: 
    TK_IDENTIFICADOR '(' lista_argumentos ')'

lista_argumentos: 
    expressao ',' lista_argumentos
    | expressao

comando_retorno: 
    TK_PR_RETURN expressao 

comando_controle_fluxo: 
    TK_PR_IF '(' expressao ')' bloco_comandos
    | TK_PR_IF '(' expressao ')' bloco_comandos TK_PR_ELSE bloco_comandos 
    | TK_PR_WHILE '(' expressao ')' bloco_comandos 


/* ============================== EXPRESSOES ============================== */

expressao: expr7

expr7: 
    expr7 TK_OC_OR expr6
    | expr6

expr6: 
    expr6 TK_OC_AND expr5
    | expr5

expr5: 
    expr5 TK_OC_NE expr4
    | expr5 TK_OC_EQ expr4
    | expr4

expr4:
    expr4 '<' expr3
    | expr4 '>' expr3
    | expr4 TK_OC_LE expr3
    | expr4 TK_OC_GE expr3
    | expr3

expr3: 
    expr3 '+' expr2
    | expr3 '-' expr2
    | expr2

expr2: 
    expr2 '*' expr1 
    | expr2 '/' expr1 
    | expr2 '%' expr1 
    | expr1 ;

expr1: 
    '-' expr1 
    | '!' expr1 
    | TK_LIT_FLOAT 
    | TK_LIT_INT 
    | TK_IDENTIFICADOR 
    | chamada_funcao  
    | '(' expressao ')' 


```


## Etapa 05 

