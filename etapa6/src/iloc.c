#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "iloc.h"

/*
* Gera uma nova instrução ILOC
*/
char* GeraTemp() {
    static int temp_counter = 1; 
    size_t size = snprintf(NULL, 0, "r%d", temp_counter) + 1; 
    char* temp = (char*)malloc(size); 
    if (!temp) {
        fprintf(stderr, "Erro: Falha ao alocar memória para GeraTemp().\n");
        exit(EXIT_FAILURE);
    }
    snprintf(temp, size, "r%d", temp_counter++); 
    return temp;
}

/*
* Gera um nome único para um rótulo
*/
char* GeraLabel() {
    static int label_counter = 0; 
    size_t size = snprintf(NULL, 0, "L%d", label_counter) + 1; 
    char* label = (char*)malloc(size); 
    if (!label) {
        fprintf(stderr, "Erro: Falha ao alocar memória para GeraLabel().\n");
        exit(EXIT_FAILURE);
    }
    snprintf(label, size, "L%d:", label_counter++); 
    return label;
}


IlocInstruction_t* new_ILOC_instruction(const char* op, const char* arg1, const char* arg2, const char* arg3) {
    IlocInstruction_t* ret = NULL;
    ret = (IlocInstruction_t*)calloc(1,sizeof(IlocInstruction_t));
    if (ret != NULL) {
        ret->op = strdup(op);
        ret->arg1 = strdup(arg1);
        ret->arg2 = strdup(arg2);
        ret->arg3 = strdup(arg3);
    }
    return ret;
}


IlocInstruction_t* nova_instrucao(char* operacao, char* arg1, char* arg2, char* arg3) {
    IlocInstruction_t* instrucao = (IlocInstruction_t*)calloc(1, sizeof(IlocInstruction_t));
    if (!instrucao) return NULL;

    instrucao->op = strdup(operacao);
    instrucao->arg1 = arg1 ? strdup(arg1) : NULL;
    instrucao->arg2 = arg2 ? strdup(arg2) : NULL;
    instrucao->arg3 = arg3 ? strdup(arg3) : NULL;

    return instrucao;
}

IlocList_t* nova_lista_instrucoes() {
    return NULL;
}

void add_instrucao(IlocList_t** lista, IlocInstruction_t* instrucao) {
    IlocList_t* novo_no = (IlocList_t*)calloc(1, sizeof(IlocList_t));
    if (!novo_no) return;

    novo_no->instruction = instrucao;
    novo_no->next = *lista;
    *lista = novo_no;
}

IlocList_t* criaInstrucao(char* operacao, char* arg1, char* arg2, char* arg3) {
    IlocList_t* lista = nova_lista_instrucoes();
    IlocInstruction_t* instrucao = nova_instrucao(operacao, arg1, arg2, arg3);

    if (!instrucao) {
        free(lista);
        return NULL;
    }

    add_instrucao(&lista, instrucao);
    return lista;
}


void imprimeIlocInstruction(const IlocInstruction_t* instrucao) {
    /* Flag: imprimir codigo ILOC como comentario*/
    #ifdef COMMENT_ILOC
        printf("\t# ");
    #endif

    if (!instrucao) {
        fprintf(stderr, "Erro: Instrução nula.\n");
        return;
    }

    printf("%s", instrucao->op ? instrucao->op : "NULL");

    if (strcmp(instrucao->op, "storeAI") == 0 || strcmp(instrucao->op, "cbr") == 0) {
        if (instrucao->arg1) printf(" %s", instrucao->arg1);
        if (instrucao->arg2) printf(" => %s", instrucao->arg2);
        if (instrucao->arg3) printf(", %s", instrucao->arg3);
    } else if (strcmp(instrucao->op, "jumpI") == 0) {
       if (instrucao->arg1) printf(" => %s", instrucao->arg1);
    } else if (strcmp(instrucao->op, "loadI") == 0) {
        if (instrucao->arg1) printf(" %s", instrucao->arg1);
       if (instrucao->arg1) printf(" => %s", instrucao->arg3);
    } 
    else { // Outras instruções
        if (instrucao->arg1) printf(" %s", instrucao->arg1);
        if (instrucao->arg2) printf(", %s", instrucao->arg2);
        if (instrucao->arg3) printf(" => %s", instrucao->arg3);
    }


    printf("\n");
}

void imprimeListaIlocInstructions(const IlocList_t* lista) {
    if (!lista) {
        printf("A lista está vazia.\n");
        return;
    }
    printf("# [ILOC] =============================\n");

    const IlocList_t* atual = lista;
    while (atual) {
        imprimeIlocInstruction(atual->instruction);
        atual = atual->next;
    }
}

IlocList_t* concatenaInstrucoes(IlocList_t* lista1, IlocList_t* lista2) {
    if (!lista1) return lista2; 
    if (!lista2) return lista1; 

    IlocList_t* atual = lista1;

    while (atual->next != NULL) {
        atual = atual->next;
    }

    atual->next = lista2;

    return lista1;
}
