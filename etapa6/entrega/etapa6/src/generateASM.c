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
    if (instr->op[0] == 'L') {
        printf("\n%s:\n", instr->op);
    }
    else if (strcmp(instr->op, "loadI") == 0) {
        /*  ILOC: loadI 10 => r1
         *   ASM: movl $10, %r1 */
        char* dest = allocateRegister(instr->arg3);
        printf("\tmovl\t$%s, %s", instr->arg1, dest);
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

    } else if (strcmp(instr->op, "RETURN") == 0){ 
        // IlocInstruction_t *temp = instr;
        printf("\tret\n");
    } else if (strcmp(instr->op, "jumpI") == 0) {
        /*  ILOC: jumpI => L1
         *   ASM: jmp L1
         */
        printf("\tjmp\t%s", instr->arg1);
        imprimeIlocInstruction(instr);
    } else if (strcmp(instr->op, "cbr") == 0) {
        /*  ILOC: cbr r1 => L1, L2
         *   ASM: cmpl $0, r1
         *        je L2
         *        jmp L1
         */
        char* src = allocateRegister(instr->arg1);
        printf("\tcmpl\t$0, %s\n", src);
        printf("\tje\t%s\n", instr->arg3);
        printf("\tjmp\t%s", instr->arg2);
        imprimeIlocInstruction(instr);
    } else {
        ComparisonType cmp = string_to_comparison_type(instr->op);
        BinaryOperationType binOp = string_to_binary_operation_type(instr->op);

        if (cmp != cmp_UNKNOWN) {
            handleComparison(cmp, instr);
        } 
        else if (binOp != bin_UNKNOWN) {
            handleBinaryOperation(binOp, instr);
        } 
        else if (strcmp(instr->op, "and") == 0 || strcmp(instr->op, "or") == 0 || strcmp(instr->op, "not") == 0) {
            handleLogicalOperation(instr);
        } 
        else { 
            fprintf(stderr, "Operacao Invalida : %s\n", instr->op);
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
    printf("\t# Prologo\n");
    printf("\tpushq\t%%rbp\n");
    printf("\tmovq\t%%rsp, %%rbp\n");

    // ================================================
    printf("\n\t;#Main \n");
    // ================================================

    // Traduzir cada instrução ILOC para Assembly
    IlocList_t* current = ilocList;
    while (current != NULL) {
        /* if operation === RETURN:  */
        if(strcmp(current->instruction->op, "RETURN") == 0){
            nextFreeRegister = 0; /* Disclaimer: Assim o EAX sera usado*/
            translateIlocToAsm(current->next->instruction);    
            current = current->next->next;
            continue;
        }

        translateIlocToAsm(current->instruction);
        current = current->next;
    }
    
    printf("\tpopq\t%%rbp\n");
    printf("\tret\n");
}

/* ======================================================= 
 *  Alocacao de Registradores
 * ======================================================= */

char* allocateRegister(char* virtualReg) {
    // Verifica se já existe mapeamento
    for (int i = 0; i < nextFreeRegister; i++) {
        // printf("\n=============== virtualReg: %s\n", virtualReg);
        if (strcmp(registerMapping[i].virtualReg, virtualReg) == 0) {
            return registerMapping[i].physicalReg;
        }
    }

    // Se todos os registradores físicos estão ocupados, reutiliza o primeiro
    nextFreeRegister = nextFreeRegister >= NUM_REGISTERS ? 0 : nextFreeRegister;

    char* physicalReg;
    switch (nextFreeRegister) {
        case 0: physicalReg = "%r8d"; break;
        case 1: physicalReg = "%r9d"; break;
        case 2: physicalReg = "%r10d"; break;
        case 3: physicalReg = "%r11d"; break;
        case 4: physicalReg = "%r12d"; break;
        case 5: physicalReg = "%r13d"; break;
        case 6: physicalReg = "%r14d"; break;
        case 7: physicalReg = "%r15d"; break;
        case 8: physicalReg = "%eax"; break;
        case 9: physicalReg = "%ebx"; break;
        case 10: physicalReg = "%ecx"; break;
        case 11: physicalReg = "%edx"; break;
        case 12: physicalReg = "%esi"; break;
        case 13: physicalReg = "%edi"; break;
        default:
            physicalReg = "UNKNOWN";
            break;
    }
    
    registerMapping[nextFreeRegister].virtualReg = strdup(virtualReg);
    registerMapping[nextFreeRegister].physicalReg = strdup(physicalReg);
    nextFreeRegister++;

    return physicalReg;
}
/* ======================================================= 
 *  Comparacao
 * ======================================================= */

void handleComparison(ComparisonType cmp, IlocInstruction_t* instrucao) {
    /* ref: https://cs.wellesley.edu/~cs240/s16/slides/x86-control.pdf ;
     * slide 5;
     */
    char* s1 = allocateRegister(instrucao->arg2);
    char* s2 = allocateRegister(instrucao->arg1);
    char *dest = allocateRegister(instrucao->arg3);
    
    printf("\n");
    imprimeIlocInstruction(instrucao);
    printf("\tcmpl\t%s, %s\n", s1, s2);
    
    switch (cmp) {
        case cmp_LT:
            printf("\tsetl\t%%al\n");
            break;
        case cmp_GT:
            printf("\tsetg\t%%al\n");
            break;
        case cmp_LE:
            printf("\tsetle\t%%al\n");
            break;
        case cmp_GE:
            printf("\tsetge\t%%al\n");
            break;
        case cmp_EQ:
            printf("\tsete\t%%al\n");
            break;
        case cmp_NE:
            printf("\tsetne\t%%al\n");
            break;
        default:
            break;
    }

    printf("\tmovzbl\t%%al, %s \n\n", dest);  
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
/* ======================================================= 
 *  Operacoes Binarias (Aritmeticas) 
 * ======================================================= */
 
BinaryOperationType string_to_binary_operation_type(const char* op) {
    if (strcmp(op, "add") == 0) {
        return bin_ADD;
    } else if (strcmp(op, "sub") == 0) {
        return bin_SUB;
    } else if (strcmp(op, "mul") == 0) {
        return bin_MUL;
    } else if (strcmp(op, "div") == 0) {
        return bin_DIV;
    } else if (strcmp(op, "mod") == 0) {
        return bin_MOD;
    }
    else {
        return bin_UNKNOWN;
    }
}

void handleBinaryOperation(BinaryOperationType binOp, IlocInstruction_t* instrucao) {
    /* Lógica para operações binárias
     * O código assembly gerado depende do tipo da operação binária.
     */
    char* s1 = allocateRegister(instrucao->arg2) != NULL ? allocateRegister(instrucao->arg2) : NULL;
    char* s2 = allocateRegister(instrucao->arg1) != NULL ? allocateRegister(instrucao->arg1) : NULL;
    char* dest = allocateRegister(instrucao->arg3);
    
    printf("\n");
    imprimeIlocInstruction(instrucao);
    
    switch (binOp) {
        case bin_ADD:
            printf("\taddl\t%s, %s\n", s1, s2);
            printf("\tmovl\t%s, %s\n", s2, dest);
            break;
        case bin_SUB:
            printf("\tsubl\t%s, %s\n", s1, s2);
            printf("\tmovl\t%s, %s\n", s2, dest);
            break;
        case bin_MUL:
            printf("\timull\t%s, %s\n", s1, s2);
            printf("\tmovl\t%s, %s\n", s2, dest);
            break;
        case bin_DIV:
            printf("\tmovl\t%s, %%eax\n", s1);
            printf("\tcltd\n");
            printf("\tidivl\t%s\n", s2);
            printf("\tmovl\t%%eax, %s\n", dest);
            break;
        case bin_MOD:
            printf("\tcltd\n");
            printf("\tidivl\t%s\n", s2); 
            printf("\tmovl\t%%edx, %s\n", dest);  
            break;
        default:
            printf("Unknown binary operation\n");
            break;
    }
    
    printf("\n");
}

/* ======================================================= 
 * Operacoes Logicas: AND,OR y NOT 
 * ======================================================= */
void handleLogicalOperation(IlocInstruction_t* instr) {
    char* s1 = allocateRegister(instr->arg1);
    char* s2 = instr->arg2 != NULL ? allocateRegister(instr->arg2) : NULL;
    char* dest = allocateRegister(instr->arg3);

    printf("\n");
    imprimeIlocInstruction(instr);

    if (strcmp(instr->op, "and") == 0) {
        printf("\tandl\t%s, %s\n", s1, s2);
        printf("\tmovl\t%s, %s\n", s2, dest);
    } 
    else if (strcmp(instr->op, "or") == 0) {
        printf("\torl\t%s, %s\n", s1, s2);
        printf("\tmovl\t%s, %s\n", s2, dest);
    } else if (strcmp(instr->op, "not") == 0) {
        printf("\tnotl\t%s\n", s1);
        printf("\tmovl\t%s, %s\n", s1, dest);
    } else {
        fprintf(stderr, "Operacao logica desconhecida: %s\n", instr->op);
    }
}
