


# Etapa 06 

## Sobre ILOC : Etapa 05 
- Foram realizados alguns ajustes na geração de código mas a estrutura está a mesma 
- Haviam alguns erros de desatenção como por exemplo, estava gerando código `mul` em vez de `mult`
- Atribuição de números negativos precisou de uma pequena correção 
- Apesar de não ser o ideal, devido às situações, prazos etc. preservamos as funções criadas na etapa05 no arquivo parser.y
- => Começamos tentar criar funções e #defines demais pra otimizar o código após a etapa 04 que na hora de implementar a etapa 05 ficou curto o tempo e mais confundiu que ajudou

## ASM : Etapa 06
- para etapa 06 foi criada uma flag que faz com que todo o código ILOC seja comentado no inicio do arquivo. 
- A partir da Lista de Instruções Iloc serão impressas as instruções ASM
- A estrutura inicial foi esta 
```c
/* Função principal para gerar e imprimir o código Assembly */
void generateASM(IlocList_t* ilocList);

/* Função para traduzir cada instrução ILOC para Assembly */
void translateIlocToAsm(IlocInstruction_t* instr, int isEnd);

/* Função para alocar registradores */
char* allocateRegister(char* virtualReg) ;

/* ======================================================= */
```
com funcoe auxiliares que servem mais como um "switchzao" 
```c
    ComparisonType string_to_comparison_type(const char* str);
    void handleComparison(ComparisonType cmp, IlocInstruction_t* instrucao);

    /* Operacoes Binarias (Aritmeticas) */
    BinaryOperationType string_to_binary_operation_type(const char* op) ;
    void handleBinaryOperation(BinaryOperationType binOp, IlocInstruction_t* instrucao);

    // cujas estruturas de dados sao 
    typedef enum {
    cmp_LT,
    cmp_GT,
    cmp_LE,
    cmp_GE,
    cmp_EQ,
    cmp_NE,
    cmp_UNKNOWN
} ComparisonType;

/* Mapeia: Operacoes Binarias (Aritmeticas) */
typedef enum {
    bin_ADD,
    bin_SUB,
    bin_MUL,
    bin_DIV,
    bin_MOD,
    bin_RSUBI,
    bin_UNKNOWN
} BinaryOperationType;

```

## Otimizações 
No entanto, como não foi criado um controle de alocação de registradores, uma alternativa foi reduzir número total de instruções. Tendo em vista o tamanho dos casos testes esta pareceu uma alternativa razoável.
Talvez tenha tido a contrapartida de "poluir" mais a funcao principal, `generateASM()`,com uma sequência de `else if`s mas foi uma escolha consciente.

```c
  ; # Exemplo: Uma simples operacao de incremento que gerava 5 operacoes poderia ser reduzida para apenas uma
  ; # Simplificar: 
            movl	-4(%rbp), %r15d	 
            movl	$1, %r8d	
            subl	%r8d, %r9d
            movl	%r9d, %r10d
            movl	%r10d, -4(%rbp)	
  ; # Para: 
            subl	$1, -4(%rbp) 
```