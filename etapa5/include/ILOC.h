// #pragma once


// typedef struct ILOCOP
// {
//     char* label;   // label da operacao
//     char* op_name; // nome da operacao
//     char* op_1;    // operando 1
//     char* op_2;    // operando 2
//     char* target;  // guess what this represents
//     int num_op;    // numero de operandos da instrucao
// }IlocOp_t;


// typedef struct OPLIST
// {
//     IlocOp_t* instruction;
//     OpList_t* next;

// }OpList_t;

// // ==============  operation functions  ==============
// IlocOp_t* new_ILOC_instruction(const char* name, const char* operator_1, const char* operator_2, const char* target, const char* label);

// void free_ILOC_instruction(IlocOp_t* instruction);

// void print_ILOC_instruction(IlocOp_t* instruction);



// // ==============  list functions  ==============
// OpList_t* new_ILOC_instruction_list(IlocOp_t* instruction);

// void free_ILOC_instruction_list(OpList_t* lista);

// OpList_t* get_last_ILOC_list(OpList_t* lista);

// void ILOC_list_append_instruction(OpList_t* lista, OpList_t* filho);

// void print_ILOC_list(OpList_t* lista);