#ifndef ILOC_H  
#define ILOC_H

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

char* GeraTemp();     
char* GeraRotulo();   


IlocInstruction_t* new_ILOC_instruction(const char* op, const char* arg1, const char* arg2, const char* arg3);
IlocInstruction_t* nova_instrucao(char* operacao, char* arg1, char* arg2, char* arg3) ;
IlocList_t* nova_lista_instrucoes();
void add_instrucao(IlocList_t** lista, IlocInstruction_t* instrucao);
IlocList_t* criaInstrucao(char* operacao, char* arg1, char* arg2, char* arg3);




void imprimeIlocInstruction(const IlocInstruction_t* instrucao);
void imprimeListaIlocInstructions(const IlocList_t* lista);

IlocList_t* concatenaInstrucoes(IlocList_t* lista1, IlocList_t* lista2);


#endif