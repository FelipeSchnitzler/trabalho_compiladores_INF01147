#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "iloc.h"

/*
============================================================================================
 ASSEMBLY GENERATION
===============================================================================================
*/
#define NUM_REGISTERS 8 

typedef struct {
    char* virtualReg;   /* Registradores ILOC: R1,R2...R12,R13..*/
    char* physicalReg;  
} RegisterMap;

void generateASM(IlocList_t* ilocList);
void translateIlocToAsm(IlocInstruction_t* instr);
char* allocateRegister(char* virtualReg) ;


