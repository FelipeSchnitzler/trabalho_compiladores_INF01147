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

typedef struct Dado
{
    TipoDado tipo;
} TipoDado_t;

TipoDado_t GeraDado(TipoDado tipo);


typedef struct Symbol {
    char *nome;             
    int linha;              
    Natureza natureza;      
    TipoDado tipo;          
    struct Symbol *next;
} Symbol;

typedef struct SymbolTable {
    Symbol *head;
} SymbolTable;

typedef struct SymbolTableStack {
    SymbolTable *table;
    struct SymbolTableStack *next;
} SymbolTableStack;


SymbolTable *create_table();

void free_table(SymbolTable *table);

Symbol *insert_symbol(SymbolTable *table, const char *name, int linha, Natureza natureza, TipoDado type);

Symbol *find_symbol(SymbolTable *table, const char *name);

void set_symbol_type(SymbolTable *table, TipoDado type);

SymbolTableStack *create_stack();

void push_table(SymbolTableStack **stack);

void pop_table(SymbolTableStack **stack);

Symbol *find_symbol_in_stack(SymbolTableStack *stack, const char *name);


void free_stack(SymbolTableStack *stack);

void print_table(SymbolTable *table);
void print_stack(SymbolTableStack *stack);
#endif
