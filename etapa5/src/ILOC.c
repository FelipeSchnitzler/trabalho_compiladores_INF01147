#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ILOC.h"

// ==============  operation functions  ==============
IlocOp_t* new_ILOC_instruction(const char* name, const char* operator_1, const char* operator_2, const char* target, const char* label){
    IlocOp_t* ret = NULL;
    ret = calloc(1,sizeof(IlocOp_t));
    if (ret != NULL)
    {
        ret->label = (label == NULL) ? NULL : strdup(label);
        ret->op_name = strdup(name);

        //goofy looking code bc any operand can be null        
        ret->num_op = 0;
        if (operator_1 != NULL)
        {
            ret->op_1 = strdup(operator_1);
            ret->num_op++;
        }else
        {
            ret->op_1 = NULL;
        }

        if (operator_2 != NULL)
        {
            ret->op_2 = strdup(operator_2);
            ret->num_op++;
        }else
        {
            ret->op_1 = NULL;
        }
        
        
        ret->target = strdup(target);

    }
    return ret;
}

void free_ILOC_instruction(IlocOp_t* instruction){
    free(instruction->label);
    free(instruction->op_name);
    free(instruction->op_1);
    free(instruction->op_2);
    free(instruction->target);
}

void print_ILOC_instruction(IlocOp_t* instruction){
    if (instruction->label != NULL)
    {
        fprintf(stdout,"%2s:\t",instruction->label);
    }else
    {
        fprintf(stdout,"   \t");
    }
    
    fprintf(stdout,"%8s",instruction->op_name);

    if (instruction->num_op == 0)
    {
        //should only happen to jumpI
       fprintf(stdout,"\t\t-> %2s",instruction->target);
       return;
    }

    //print 1ro operando
    fprintf(stdout,"%2s",instruction->op_1);

    if (instruction->num_op == 2)
    {
        fprintf(stdout,", %2s\t=>%2s\n",instruction->op_2,instruction->target);
    }
    else
    {
        fprintf(stdout,"    \t=>%s\n",instruction->target);
    }
}



// ==============  list functions  ==============
OpList_t* new_ILOC_instruction_list(IlocOp_t* instruction){
    OpList_t* ret = NULL;
    ret = calloc(1,sizeof(OpList_t));
    if (ret != NULL)
    {
        ret->instruction = instruction;
        ret->next = NULL;
    }
    return ret;
}

void free_ILOC_instruction_list(OpList_t* lista){
    free_ILOC_instruction(lista->instruction);
    if (lista->next != NULL)
    {
        free_ILOC_instruction_list(lista->next);
    }    
}


OpList_t* get_last_ILOC_list(OpList_t* lista){
    for (; lista->next != NULL; lista = lista->next){} //sorry for this line
    return lista;    
}

void ILOC_list_append_instruction(OpList_t* lista, OpList_t* filho){
    lista = get_last_ILOC_list(lista);
    lista->next = realloc(filho,sizeof(OpList_t));
}

void print_ILOC_list(OpList_t* lista){
    do
    {
        print_ILOC_instruction(lista->instruction);
        lista = lista->next;
    } while (lista->next != NULL);
}