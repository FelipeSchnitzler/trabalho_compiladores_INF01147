#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table.h"

SymbolTable *create_table() {
    SymbolTable *table = (SymbolTable *)malloc(sizeof(SymbolTable));
    table->head = NULL;
    return table;
}

void free_table(SymbolTable *table) {
    Symbol *current = table->head;
    while (current) {
        Symbol *temp = current;
        current = current->next;
        free(temp->name);
        free(temp->type);
        free(temp);
    }
    free(table);
}

bool insert_symbol(SymbolTable *table, const char *name, const char *type) {
    if (!table || find_symbol(table, name)) return false;
    Symbol *symbol = (Symbol *)malloc(sizeof(Symbol));
    symbol->name = strdup(name);
    symbol->type = strdup(type);
    symbol->next = table->head;
    table->head = symbol;
    return true;
}

Symbol *find_symbol(SymbolTable *table, const char *name) {
    Symbol *current = table->head;
    while (current) {
        if (strcmp(current->name, name) == 0) return current;
        current = current->next;
    }
    return NULL;
}

SymbolTableStack *create_stack() {
    return NULL;
}

void push_table(SymbolTableStack **stack) {
    SymbolTableStack *new_node = (SymbolTableStack *)malloc(sizeof(SymbolTableStack));
    new_node->table = create_table();
    new_node->next = *stack;
    *stack = new_node;
}

void pop_table(SymbolTableStack **stack) {
    if (!*stack) return;
    SymbolTableStack *temp = *stack;
    *stack = (*stack)->next;
    free_table(temp->table);
    free(temp);
}

Symbol *find_symbol_in_stack(SymbolTableStack *stack, const char *name) {
    while (stack) {
        Symbol *symbol = find_symbol(stack->table, name);
        if (symbol) return symbol;
        stack = stack->next;
    }
    return NULL;
}

void free_stack(SymbolTableStack *stack) {
    while (stack) {
        SymbolTableStack *temp = stack;
        stack = stack->next;
        free_table(temp->table);
        free(temp);
    }
}
