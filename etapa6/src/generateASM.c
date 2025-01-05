#include "generateASM.h"

/*
===========================================================================================
 Facilitadores
==============================================================================================
*/
RegisterMap registerMapping[NUM_REGISTERS]; 
int nextFreeRegister = 0; 

/*
============================================================================================
 ASSEMBLY GENERATION
===============================================================================================
*/

/* Função auxiliar para traduzir ILOC para Assembly */
void translateIlocToAsm(IlocInstruction_t* instr) {
    if (strcmp(instr->op, "loadI") == 0) {
        /*  ILOC: loadI 10 => r1
        *   ASM: movl $10, %r1
        */
        char* dest = allocateRegister(instr->arg3);
        printf("\tmovl\t$%s, %s\n", instr->arg1, dest);
        imprimeIlocInstruction(instr);

    } else if (strcmp(instr->op, "storeAI") == 0) {
        /* ILOC: storeAI r1 => rfp, offset
         * ASM: movl r1, offset(%rbp)
         */
        char* src = allocateRegister(instr->arg1);
        printf("\tmovl\t%s, -%s(%%rbp)", src, instr->arg3);
        imprimeIlocInstruction(instr);
    } else if (strcmp(instr->op, "loadAI") == 0) {
        /*  ILOC: loadAI rfp, offset => r1
         *   ASM: movl offset(%rbp), r1
         */         
        char* dest = allocateRegister(instr->arg3);
        printf("\tmovl\t-%s(%%rbp), %s", instr->arg2, dest);
        imprimeIlocInstruction(instr);

    } else if (strcmp(instr->op, "add") == 0) {
        // ILOC: add r1, r2 => r3
        // ASM: addl r2, r1; movl r1, r3
        printf("\taddl\t%%r%s, %%r%s\n", instr->arg2, instr->arg1);
        printf("\tmovl\t%%r%s, %%r%s\n", instr->arg1, instr->arg3);

    }else if (strcmp(instr->op, "RETURN") == 0){ 
        // IlocInstruction_t *temp = instr;
        printf("\tret\n");
    } else {
        ComparisonType cmp = string_to_comparison_type(instr->op);
        if (cmp != cmp_UNKNOWN) {
            handleComparison(cmp);
        } else { 
            fprintf(stderr, "Unsupported operation: %s\n", instr->op);
        }
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

    // ================================================
    printf("\n\t# Variáveis locais\n");
    // ================================================

    // Traduzir cada instrução ILOC para Assembly
    IlocList_t* current = ilocList;
    while (current != NULL) {
        /*--- RETURN -------- */
        if(strcmp(current->instruction->op, "RETURN") == 0){
            /* Disclaimer: Assim o EAX sera usado*/
            nextFreeRegister = 0; 
            translateIlocToAsm(current->next->instruction);    
            current = current->next->next;
            continue;
        }

        translateIlocToAsm(current->instruction);
        current = current->next;
    }
    
    // linha abaixo ja esta sendo incluida no if(op == RETURN)
    // printf("\tmovl\t$0, %%eax\n"); 
    printf("\tpopq\t%%rbp\n");
    printf("\tret\n");
}


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

// Função que trata os tipos de comparação
void handleComparison(ComparisonType cmp) {
    switch (cmp) {
        case cmp_LT:
            printf("Handling cmp_LT\n");
            break;
        case cmp_GT:
            printf("Handling cmp_GT\n");
            break;
        case cmp_LE:
            printf("Handling cmp_LE\n");
            break;
        case cmp_GE:
            printf("Handling cmp_GE\n");
            break;
        case cmp_EQ:
            printf("Handling cmp_EQ\n");
            break;
        case cmp_NE:
            printf("Handling cmp_NE\n");
            break;
        default:
            printf("Unknown comparison type\n");
            break;
    }
}

ComparisonType string_to_comparison_type(const char* str) {
    if (strcmp(str, "cmp_LT") == 0) return cmp_LT;
    if (strcmp(str, "cmp_GT") == 0) return cmp_GT;
    if (strcmp(str, "cmp_LE") == 0) return cmp_LE;
    if (strcmp(str, "cmp_GE") == 0) return cmp_GE;
    if (strcmp(str, "cmp_EQ") == 0) return cmp_EQ;
    if (strcmp(str, "cmp_NE") == 0) return cmp_NE;

    return cmp_UNKNOWN;  // Retorna cmp_UNKNOWN se não for encontrado
}