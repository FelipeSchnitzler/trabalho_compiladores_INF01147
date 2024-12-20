#pragma once
#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdbool.h> // Mapeia 0 para false e qualquer outro valor para true


typedef enum {
    IDENTIFICADOR,
    FUNCAO
} Natureza;

typedef enum {
    INT,
    FLOAT,
    INDEFINIDO,
} TipoDado;


/*
 * Estrutura de um símbolo ( entrada na tabela de símbolos )
 * Equivalente a uma "linha" da tabela de símbolos
 */
typedef struct Symbol {
    char *nome;             
    int linha;              
    Natureza natureza;      
    TipoDado tipo;
    int tamanho;
    int deslocamento;
    struct Symbol *next;
} Symbol;

typedef struct SymbolTable {
    Symbol *head;
    int deslocamento;
} SymbolTable;

typedef struct SymbolTableStack {
    SymbolTable *table;
    struct SymbolTableStack *next;
} SymbolTableStack;


/*
 * Cria uma nova tabela de símbolos vazia
 */
SymbolTable *create_table();

/*
 * Libera a memória alocada para a tabela de símbolos
 */
void free_table(SymbolTable *table);

/*
 * [TableFunction] Insere um novo símbolo na tabela de símbolos
*/
Symbol *insert_symbol(SymbolTable *table, const char *name, int linha, Natureza natureza, TipoDado type);

/*
 * [TableFunction] Busca um símbolo na tabela de símbolos
 */
Symbol *find_symbol(SymbolTable *table, const char *name);


/* ========== Stack Functions =============================== */
/* 
* [StackFunction] Cria uma nova pilha de tabelas de símbolos vazia
*/
SymbolTableStack *create_stack();

/*
 * [StackTableFunction] Cria Tabela e logo já empilha
 */
void push_table(SymbolTableStack **stack);

/*
 *  [StackTableFunction] Desempilha a tabela mais acima 
 */
void pop_table(SymbolTableStack **stack);


/*
 * [StackTableFunciton] 
 * Dada uma tabela de símbolos e o nome de um símbolo, 
 * retorna o símbolo se ele existir na tabela, ou NULL caso contrário
 */
Symbol *find_symbol_in_stack(SymbolTableStack *stack, const char *name);

/*
*  Usado quando há 
* declaracao_variavel: tipo lista_de_identificadores
*/
void set_symbol_type(SymbolTable *table, TipoDado type);

/*
 *  Libera a memória alocada para a pilha de tabelas de símbolos
*/
void free_stack(SymbolTableStack *stack);

/*
 * Funcoes auxiliares para debug
 */
void print_table(SymbolTable *table);
void print_stack(SymbolTableStack *stack);
#endif
