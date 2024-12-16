#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table.h"


// [ACTION] { $$ = GeraDado(INT); }
TipoDado_t GeraDado(TipoDado tipo){
    TipoDado_t dado;
    dado.tipo = tipo;
    return dado;
}

/*
 * Cria uma nova tabela de símbolos vazia
 */
SymbolTable *create_table() {
    SymbolTable *table = NULL;
    table = calloc(1,sizeof(SymbolTable));
    table->head = NULL;
    return table;
}

/*
 * Libera a memória alocada para a tabela de símbolos
 */
void free_table(SymbolTable *table) {
    Symbol *current = table->head;
    while (current) {
        Symbol *temp = current;
        current = current->next;
        free(temp->nome);
        // free(temp->tipo);
        free(temp);
    }
    free(table);
}

/*
 * [ACTION REQUIRED] => Adicionar o **DESLOCAMENTO** na tabela de símbolos
 * Insere um símbolo na tabela de símbolos
 * params:
 *  table: ponteiro para a tabela de símbolos
 *  name: nome do símbolo
 *  linha: linha onde o símbolo foi declarado
 *  natureza: natureza do símbolo (identificador ou função)
 *  type: tipo de dado do símbolo (inteiro ou float)
 * 
 */
Symbol *insert_symbol(SymbolTable *table,const char *name, int linha, Natureza natureza, TipoDado type) {
    
    // Symbol *simbolo = find_symbol(table, name);
    // if (!table || (simbolo != NULL)) return simbolo;
    
    Symbol *symbol = NULL;
    symbol = (Symbol*) malloc(sizeof(Symbol));
    
    if (symbol == NULL)
    {
        fprintf(stderr, "Erro de alocação de memória!\n");
        exit(1);
    }
    
    symbol->nome = strdup(name);
    symbol->linha = linha;
    symbol->natureza = natureza;
    symbol->tipo = type;
    symbol->next = table->head;
    table->head = symbol;
    // print_table(table);
    return NULL;
}

/*
 * Dada uma tabela de símbolos e o nome de um símbolo, 
 * retorna o símbolo se ele existir na tabela, ou NULL caso contrário
 */
Symbol *find_symbol(SymbolTable *table, const char *name) {
    Symbol *current = table->head;
    while (current) {
        if (strcmp(current->nome, name) == 0) return current;
        current = current->next;
    }
    return NULL;
}

/*
 * Provavelmente precisa ser revisto
 */
void set_symbol_type(SymbolTable *table, TipoDado type){
    Symbol *tmp = table->head;

    for (; tmp != NULL; tmp = tmp->next)
    {
        if (tmp->tipo == INDEFINIDO)
        {
            tmp->tipo = type;
        }
    }
}

SymbolTableStack *create_stack() {
    return NULL;
}

/* 
 * [ACTION REQUIRED] => Ao Adicionar um novo escopo, é necessário criar uma nova tabela de símbolos
 *  logo, ao empilhar uma tabela é preciso passar o __DESLOCAMENTO__ de uma tabela para outra, 
 * e alguns casos quando se desempilha tambem [REVISAR] isso.
 */
void push_table(SymbolTableStack **stack) {
    SymbolTableStack *new_node = (SymbolTableStack *)malloc(sizeof(SymbolTableStack));
    new_node->table = create_table();
    new_node->next = *stack;
    *stack = new_node;
}

/* 
 * [ACTION REQUIRED] => Ao Adicionar um novo escopo, é necessário criar uma nova tabela de símbolos
 *  logo, ao empilhar uma tabela é preciso passar o __DESLOCAMENTO__ de uma tabela para outra, 
 * e alguns casos quando se desempilha tambem [REVISAR] isso.
 */
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

/*
 * [DEBUG] => Imprime a tabela de símbolos
 */
void print_table(SymbolTable *table) {
    if (!table || !table->head) {
        printf("Tabela de símbolos vazia.\n");
        return;
    }

    Symbol *current = table->head;
    while (current) {
        printf("%-20s %-10d %-15s %-10s\n",
               current->nome,
               current->linha,
               current->natureza == IDENTIFICADOR ? "IDENTIFICADOR" : "FUNCAO",
               current->tipo == INT ? "INT" : "FLOAT");
        current = current->next;
    }
    
}

/*
 * [DEBUG] Imprime a pilha de tabelas de símbolos
 */
void print_stack(SymbolTableStack *stack) {
    if (!stack) {
        printf("Pilha de tabelas vazia.\n");
        return;
    }

    printf("===============================================================\n");
    printf("%-20s %-10s %-15s %-10s\n", "Nome", "Linha", "Natureza", "Tipo"); // Cabeçalho
    printf("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");

    // int i = 1; // Contador para os escopos
    while (stack) {
        // Imprime uma linha separadora entre os escopos
        
        printf("---------------------------------------------------------------\n");

        // Imprime a tabela de símbolos para o escopo atual
        print_table(stack->table);  // Assume que print_table já é implementada corretamente
        stack = stack->next;
    }
    printf("===============================================================\n\n\n");
    
}