#ifndef _ARVORE_H_
#define _ARVORE_H_

#include "table.h"

typedef struct asd_tree {
  char *label;
  int number_of_children;
  TipoDado tipo;
  struct asd_tree **children;
} asd_tree_t;

/*
 * Função asd_new, cria um nó sem filhos com o label informado.
 */
asd_tree_t *asd_new(const char *label);

/*
 * Função asd_tree, libera recursivamente o nó e seus filhos.
 */
void asd_free(asd_tree_t *tree);

/*
 * Função asd_add_child, adiciona child como filho de tree.
 */
void asd_add_child(asd_tree_t *tree, asd_tree_t *child);

/*
 * Função asd_print, imprime recursivamente a árvore.
 */
void asd_print(asd_tree_t *tree);

/*
 * Função asd_print_graphviz, idem, em formato DOT
 */
void asd_print_graphviz (asd_tree_t *tree);
/*
 * Função que pega quem deve ser o pai do prox comando
 */
asd_tree_t *asd_get_last_child(asd_tree_t *tree);

/*
 * Funcao para facilitar a vida de expressoes
 */

asd_tree_t* handle_binary_operation(const char* operator, asd_tree_t* left, asd_tree_t* right);

asd_tree_t *asd_new_with_1_child(const char *label, asd_tree_t *child1);

TipoDado type_inference(TipoDado tipo1, TipoDado tipo2);

asd_tree_t *make_IDENTIFICADOR(const char *label,const char *nome_identificador,const char *valor);

#endif //_ARVORE_H_
