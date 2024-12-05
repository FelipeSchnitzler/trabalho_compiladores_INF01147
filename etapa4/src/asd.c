#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "asd.h"
#define ARQUIVO_SAIDA "saida.dot"
#define expected_children_count 2

asd_tree_t *asd_new(const char *label)
{
  asd_tree_t *ret = NULL;
  ret = calloc(1, sizeof(asd_tree_t));
  if (ret != NULL){
    ret->label = strdup(label);
    ret->number_of_children = 0;
    // ret->tipo = INDEFINIDO;
    ret->children = NULL;
  }
  return ret;
}

void asd_free(asd_tree_t *tree)
{
  if (tree != NULL){
    int i;
    for (i = 0; i < tree->number_of_children; i++){
      asd_free(tree->children[i]);
    }
    free(tree->children);
    free(tree->label);
    free(tree);
  }else{
    // printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_add_child(asd_tree_t *tree, asd_tree_t *child)
{
  if (tree != NULL && child != NULL){
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(asd_tree_t*));
    tree->children[tree->number_of_children-1] = child;
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p / %p.\n", __FUNCTION__, tree, child);
  }
}

static void _asd_print (FILE *foutput, asd_tree_t *tree, int profundidade)
{
  int i;
  if (tree != NULL){
    fprintf(foutput, "%d%*s: Nó '%s' tem %d filhos:\n", profundidade, profundidade*2, "", tree->label, tree->number_of_children);
    for (i = 0; i < tree->number_of_children; i++){
      _asd_print(foutput, tree->children[i], profundidade+1);
    }
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_print(asd_tree_t *tree)
{
  FILE *foutput = stderr;
  if (tree != NULL){
    _asd_print(foutput, tree, 0);
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

static void _asd_print_graphviz (FILE *foutput, asd_tree_t *tree)
{
  int i;
  if (tree != NULL){
    fprintf(foutput, "  %ld [ label=\"%s\" ];\n", (long)tree, tree->label);
    for (i = 0; i < tree->number_of_children; i++){
      fprintf(foutput, "  %ld -> %ld;\n", (long)tree, (long)tree->children[i]);
      _asd_print_graphviz(foutput, tree->children[i]);
    }
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

void asd_print_graphviz(asd_tree_t *tree)
{
  FILE *foutput = fopen(ARQUIVO_SAIDA, "w+");
  if(foutput == NULL){
    printf("Erro: %s não pude abrir o arquivo [%s] para escrita.\n", __FUNCTION__, ARQUIVO_SAIDA);
  }
    fprintf(foutput, "digraph grafo {\n");
  
  if (tree != NULL){
    _asd_print_graphviz(foutput, tree);
  }
  fprintf(foutput, "}\n");
  fclose(foutput);
    // printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
}

asd_tree_t *asd_get_last_child(asd_tree_t *tree){
  printf("AAAA\n");
  asd_tree_t *last = tree;
  
  if (last != NULL){
    int child_count = last->number_of_children;

    for (; last->children[child_count-1] != NULL && child_count > expected_children_count; last = last->children[child_count-1]) {}
    return last;
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

/*[EngSw]=======================================================================================*/

/*
 * Funcao para facilitar a vida de expressoes
 */

asd_tree_t* handle_binary_operation(const char* operator, asd_tree_t* left, asd_tree_t* right) {
    // Valida os parâmetros de entrada
    if (!operator) {
        printf("Erro em %s: operador nulo fornecido.\n", __FUNCTION__);
        return NULL;
    }
    if (!left || !right) {
        printf("Erro em %s: operandos inválidos (left = %p, right = %p).\n", __FUNCTION__, (void*)left, (void*)right);
        return NULL;
    }

    // Cria um novo nó para a operação binária
    asd_tree_t* node = asd_new(operator);
    if (!node) {
        printf("Erro em %s: falha ao alocar memória para o nó operador.\n", __FUNCTION__);
        return NULL;
    }

    // Adiciona os operandos como filhos do nó
    asd_add_child(node, left);
    asd_add_child(node, right);

    // Copia o operador de forma segura
    node->label = strdup(operator);
    if (!node->label) {
        printf("Erro em %s: falha ao copiar o operador.\n", __FUNCTION__);
        free(node);
        return NULL;
    }

    // // Calcula o tipo resultante da operação
    // node->tipo = type_inference(left->tipo, right->tipo);

    return node;
}
