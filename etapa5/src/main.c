#include "asd.h"
#include <stdio.h>
#include "table.h"
#include "errors.h"

extern int yyparse(void);
extern int yylex_destroy(void);
void exporta (void *arvore);

void *arvore = NULL;
SymbolTableStack *stack = NULL;

int main (int argc, char **argv)
{
  int ret = yyparse(); 
  #ifdef GraphvizPrint
  exporta (arvore);
  #endif
  asd_free((asd_tree_t *) arvore);
  yylex_destroy();
  return ret;
}

void exporta (void *arvore)
{ 
  if (arvore == NULL)
  {
    return;
  }
  
  asd_tree_t *arvore_p = (asd_tree_t *) arvore;
  
  
  fprintf(stdout, "%p [label=\"%s\"];\n", arvore_p, arvore_p->label);

  int i = 0;
  for (i = 0; i < arvore_p->number_of_children; i++)
  {
    exporta(arvore_p->children[i]);
    fprintf(stdout, "%p, %p\n",arvore_p,arvore_p->children[i]);
    
  }


}