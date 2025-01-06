#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "iloc.h"

/*
============================================================================================
 ASSEMBLY GENERATION
===============================================================================================
*/
#define NUM_REGISTERS 14 

typedef struct {
    char* virtualReg;   /* Registradores ILOC: R1,R2...R13,R14,R15*/
    char* physicalReg;  
} RegisterMap;

#include <stdio.h>
#include <string.h>

/* Mapeia: operacoes de comparacao */
typedef enum {
    cmp_LT,
    cmp_GT,
    cmp_LE,
    cmp_GE,
    cmp_EQ,
    cmp_NE,
    cmp_UNKNOWN // caso inválido
} ComparisonType;

/* Mapeia: Operacoes Binarias (Aritmeticas) */
typedef enum {
    bin_ADD,
    bin_SUB,
    bin_MUL,
    bin_DIV,
    bin_MOD,
    bin_UNKNOWN
} BinaryOperationType;

/* ======================================================= 
 *  Operacoes Base
 * ======================================================= */

void generateASM(IlocList_t* ilocList);
void translateIlocToAsm(IlocInstruction_t* instr);
char* allocateRegister(char* virtualReg) ;

/* ======================================================= */
/* Comparacao */
ComparisonType string_to_comparison_type(const char* str);
void handleComparison(ComparisonType cmp, IlocInstruction_t* instrucao);

/* Operacoes Binarias (Aritmeticas) */
BinaryOperationType string_to_binary_operation_type(const char* op) ;
void handleBinaryOperation(BinaryOperationType binOp, IlocInstruction_t* instrucao);


/* Operacoes Logicas: AND,OR y NOT*/
void handleLogicalOperation(IlocInstruction_t* instrucao);
/* ======================================================= */



