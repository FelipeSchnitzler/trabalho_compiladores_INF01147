#include <stdio.h>
#include "table.h"

int main() {
    SymbolTableStack *stack = create_stack();

    printf("Pushing global scope...\n");
    push_table(&stack);
    insert_symbol(stack->table, "x", "int");
    insert_symbol(stack->table, "y", "float");

    printf("Pushing local scope...\n");
    push_table(&stack);
    insert_symbol(stack->table, "z", "char");

    printf("Procurando'x' na pilha: %s\n", find_symbol_in_stack(stack, "x") ? "Encontrou" : "Nao Encontrou");
    printf("Procurando'z' na pilha: %s\n", find_symbol_in_stack(stack, "z") ? "Encontrou" : "Nao Encontrou");
    printf("Procurando'a' na pilha: %s\n", find_symbol_in_stack(stack, "a") ? "Encontrou" : "Nao Encontrou");

    printf("Pop pilha...\n");
    pop_table(&stack);

    printf("Procurando'z' na pilha: %s\n", find_symbol_in_stack(stack, "z") ? "Encontrou" : "Nao Encontrou");

    printf("Liberando a pilha ...\n");
    free_stack(stack);

    return 0;
}
