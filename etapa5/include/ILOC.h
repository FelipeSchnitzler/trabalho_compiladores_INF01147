#pragma once

#include "asd.h"
typedef struct IlocInstruction
{
    char* op;
    char* arg1;   
    char* arg2;   
    char* arg3; 
} IlocInstruction_t;

/* 
 * Struct para a lista de instruções ILOC 
*/
typedef struct IlocList
{
    IlocInstruction_t* instruction;
    struct IlocList* next;
} IlocList_t;

char* GeraTemp();     // Gera um nome único para um temporário
char* GeraRotulo();   // Gera um nome único para um rótulo

IlocInstruction_t* new_ILOC_instruction(const char* op, const char* arg1, const char* arg2, const char* arg3);