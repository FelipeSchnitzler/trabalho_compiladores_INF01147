#pragma once
typedef enum tipo_lexico{
    LIT,
    ID
} tipo_lexico_t;

typedef struct valor_lexico {
       int linha;
       tipo_lexico_t tipo; //0-ID 1-LIT_INT 2-LIT_FLOAT
       char *valor;
    } valor_lexico_t;

valor_lexico_t *valor_lexico_new(int linha, tipo_lexico_t tipo, char *valor);
void valor_lexico_free(valor_lexico_t *valor_lexico);