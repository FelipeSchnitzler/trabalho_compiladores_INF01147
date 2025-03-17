#pragma once
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
#define NUM_TEMP_REGISTERS 8

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
    cmp_UNKNOWN 
} ComparisonType;

/* Mapeia: Operacoes Binarias (Aritmeticas) */
typedef enum {
    bin_ADD,
    bin_SUB,
    bin_MUL,
    bin_DIV,
    bin_MOD,
    bin_RSUBI,
    bin_UNKNOWN
} BinaryOperationType;

/* ======================================================= 
 *  Operacoes Base
 * ======================================================= */

/* Função principal para gerar e imprimir o código Assembly */
void generateASM(IlocList_t* ilocList);

/* Função para traduzir cada instrução ILOC para Assembly */
void translateIlocToAsm(IlocInstruction_t* instr, int isEnd);

/* Função para alocar registradores */
char* allocateRegister(char* virtualReg) ;

/* ======================================================= */
/* Comparacao */
ComparisonType string_to_comparison_type(const char* str);
void handleComparison(ComparisonType cmp, IlocInstruction_t* instrucao);

/* Operacoes Binarias (Aritmeticas) */
BinaryOperationType string_to_binary_operation_type(const char* op) ;
void handleBinaryOperation(BinaryOperationType binOp, IlocInstruction_t* instrucao);

/* Operacoes Logicas: AND,OR y NOT 
 * Gera o código assembly para operações lógicas 
*/
void handleLogicalOperation(IlocInstruction_t* instrucao);
/* ======================================================= */


void optimizeASMDivMultiplication(char *temp1, char *temp2, IlocInstruction_t* instr, IlocInstruction_t* next);


