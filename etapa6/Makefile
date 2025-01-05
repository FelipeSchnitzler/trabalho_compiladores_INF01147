UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  
	OPEN = open
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl 
	OPEN = xdg-open
endif

## ==============================================================================
ETAPA = etapa6
## ==============================================================================
CC = gcc
CFLAGS = -Iinclude -g -Wall -Wextra -DGENERAASM_ -DVERBOSE # -D_DEBUG_ #-DGraphvizPrint #-DASD_PRINT_GRAPHVIZ_FLAG
BISON_FLAGS = -d -v -Wcounterexamples

LEX_SRC = src/scanner.l
LEX_C = $(BUILD_DIR)/lex.yy.c

BISON_SRC = src/parser.y
BISON_C = $(BUILD_DIR)/parser.tab.c
BISON_H = $(BUILD_DIR)/parser.tab.h

SRC_DIR = src
BUILD_DIR = build
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC_FILES))

 
$(ETAPA): $(OBJ_FILES) $(LEX_C) $(BISON_C)
	$(CC) $(OBJ_FILES) $(LEX_C) $(BISON_C) -o $@ $(LFLAGS) $(CFLAGS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) -c $< -o $@ $(CFLAGS)

$(LEX_C): $(LEX_SRC) | $(BUILD_DIR)
	flex -o $@ $<

$(BISON_C) $(BISON_H): $(BISON_SRC) | $(BUILD_DIR)
	bison $(BISON_FLAGS) -o $(BISON_C) $<

$(BUILD_DIR): 
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(ETAPA) outputs/*.png saida.dot $(ETAPA).dSYM/

## [Entrega] ==================================================================
entrega: entrega_dir 
	
	# Cria um arquivo tar.gz contendo src, includes e Makefile
	tar -cvzf entrega/$(ETAPA).tgz src/ include/ Makefile
	
entrega_dir: clean_entrega
	echo "Criando diretório de entrega..."
	mkdir -p entrega

clean_entrega:
	echo "Limpando diretório de entrega..."
	rm -rf entrega
	echo "Diretório de entrega limpo."
	sleep 2 # Espera 2 segundos para garantir que o diretório foi removido

## [Testes] ====================================================================
## Criados de maneira experimental para ajudar no debug manual
## Dica:  use ==>   export i=$((i + 1)); make t num=$(printf "%02d" "$i")
num ?= 53
TESTE = testes/E3/z$(num)
REF = $(TESTE).ref.dot

t: tst

tst: png
	dot $(REF) -Tpng -o outputs/ref.png
	$(OPEN) outputs/ref.png 
	$(OPEN) outputs/grafo.png

png: $(ETAPA) 
	mkdir -p outputs
	./$(ETAPA) < $(TESTE)
	dot saida.dot -Tpng -o outputs/grafo.png

print_teste: 
	printf ">>>> Teste: $(TESTE)"

foo: $(ETAPA)
	./$(ETAPA) < testes/foo.ee
	dot saida.dot -Tpng -o outputs/grafo.png
	$(OPEN) outputs/grafo.png

## ==============================================================================

.PHONY: clean print_teste
