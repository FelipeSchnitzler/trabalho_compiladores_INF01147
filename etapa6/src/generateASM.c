#include "generateASM.h"

/*
===========================================================================================
 Facilitadores
==============================================================================================
*/
#define imprime_iloc_inst_como_comentario(instrucao) \
    do {                                             \
        printf("\t# ");                              \
        imprimeIlocInstruction(instrucao);           \
        printf("\n");                                \
    } while (0)

/*
============================================================================================
 ASSEMBLY GENERATION
===============================================================================================
*/

/* Função auxiliar para traduzir ILOC para Assembly */
void translateIlocToAsm(IlocInstruction_t* instr) {
    if (strcmp(instr->op, "loadI") == 0) {

        char* dest = allocateRegister(instr->arg3);
        printf("\tmovl\t$%s, %s\n", instr->arg1, dest);
    } else if (strcmp(instr->op, "storeAI") == 0) {
        char* src = allocateRegister(instr->arg1);
        // printf("\tmovl\t%%r%s, %s(%%rbp)\n", instr->arg1, instr->arg3);
        printf("\tmovl\t%s, -%s(%%rbp) # ", src, instr->arg3);

    } else if (strcmp(instr->op, "loadAI") == 0) {
        // ILOC: loadAI rfp, offset => r1
        // ASM: movl offset(%rbp), r1
        char* dest = allocateRegister(instr->arg3);
        printf("\tmovl\t%s(%%rbp), %s\n", instr->arg2, dest);
        // printf("movl $%s, %s\n", instr->arg2, dest);
        // ==================================================


        // ==================================================


    } else if (strcmp(instr->op, "add") == 0) {
        // ILOC: add r1, r2 => r3
        // ASM: addl r2, r1; movl r1, r3
        printf("\taddl\t%%r%s, %%r%s\n", instr->arg2, instr->arg1);
        printf("\tmovl\t%%r%s, %%r%s\n", instr->arg1, instr->arg3);
    } else {
        fprintf(stderr, "Unsupported operation: %s\n", instr->op);
    }
}

/* Função principal para gerar e imprimir o código Assembly */
void generateASM(IlocList_t* ilocList) {
    // Cabeçalho do Assembly
    printf("\t.file\t\"program.c\"\n");
    printf("\t.text\n");
    printf("\t.globl\tmain\n");
    printf("\t.type\tmain, @function\n");
    printf("main:\n");
    printf("\t# Prologue\n");
    printf("\tpushq\t%%rbp\n");
    printf("\tmovq\t%%rsp, %%rbp\n");

    // Traduzir cada instrução ILOC para Assembly
    IlocList_t* current = ilocList;
    while (current != NULL) {
        translateIlocToAsm(current->instruction);
        current = current->next;
    }

    // Epílogo
    printf("\n\t# Epilogue\n");
    printf("\tmovl\t$0, %%eax\n"); // Retorno 0
    printf("\tpopq\t%%rbp\n");
    printf("\tret\n");
}


RegisterMap registerMapping[NUM_REGISTERS]; 
int nextFreeRegister = 0; 

char* allocateRegister(char* virtualReg) {
    // Verifica se já existe mapeamento
    for (int i = 0; i < nextFreeRegister; i++) {
        // printf("\n=============== virtualReg: %s\n", virtualReg);
        if (strcmp(registerMapping[i].virtualReg, virtualReg) == 0) {
            return registerMapping[i].physicalReg;
        }
    }

    // Se todos os registradores físicos estão ocupados
    if (nextFreeRegister >= NUM_REGISTERS) {
        printf("Error: Out of physical registers. Consider spilling to memory.\n");
        exit(1);
    }

    // Aloca um novo registrador
    char* physicalReg;
    switch (nextFreeRegister) {
        case 0: physicalReg = "%eax"; break;
        case 1: physicalReg = "%ebx"; break;
        case 2: physicalReg = "%ecx"; break;
        case 3: physicalReg = "%edx"; break;
        case 4: physicalReg = "%esi"; break;
        case 5: physicalReg = "%edi"; break;
        case 6: physicalReg = "%r8d"; break;
        case 7: physicalReg = "%r9d"; break;
        // Adicione mais se necessário
    }

    // Adiciona ao mapeamento
    registerMapping[nextFreeRegister].virtualReg = strdup(virtualReg);
    registerMapping[nextFreeRegister].physicalReg = strdup(physicalReg);
    nextFreeRegister++;

    return physicalReg;
}

