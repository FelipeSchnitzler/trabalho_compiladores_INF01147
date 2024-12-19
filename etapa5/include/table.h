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
 * 
*/
Symbol *insert_symbol(SymbolTable *table, const char *name, int linha, Natureza natureza, TipoDado type);

Symbol *find_symbol(SymbolTable *table, const char *name);


/* ========== Stack Functions =============================== */
SymbolTableStack *create_stack();

void push_table(SymbolTableStack **stack);

void pop_table(SymbolTableStack **stack);


/*
 * Dada uma tabela de símbolos e o nome de um símbolo, 
 * retorna o símbolo se ele existir na tabela, ou NULL caso contrário
 */
Symbol *find_symbol_in_stack(SymbolTableStack *stack, const char *name);

void set_symbol_type(SymbolTable *table, TipoDado type);
void free_stack(SymbolTableStack *stack);

/*
 * Funcoes auxiliares para debug
 */
void print_table(SymbolTable *table);
void print_stack(SymbolTableStack *stack);
#endif
