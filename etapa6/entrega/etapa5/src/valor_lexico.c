#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "valor_lexico.h"

valor_lexico_t *valor_lexico_new(int linha, tipo_lexico_t tipo, char *valor)
{
    valor_lexico_t *ret = NULL;
    ret = calloc(1, sizeof(valor_lexico_t));
    if (ret != NULL)
    {
        ret->linha = linha;
        ret->tipo = tipo;
        ret->valor = strdup(valor);
    }
    return ret;
}

void valor_lexico_free(valor_lexico_t *valor_lexico)
{
  if (valor_lexico != NULL){
    free(valor_lexico->valor);
    free(valor_lexico);
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, valor_lexico);
  }
}

