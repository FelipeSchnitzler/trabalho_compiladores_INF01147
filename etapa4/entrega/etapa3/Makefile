UNAME_S := $(shell uname -s)
# Flags específicos para macOS e Linux
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl 
endif

## ========================================================================== ##
ETAPA=etapa3

CFLAGS=-Iinclude
BISON_FLAGS = -d -v -Wcounterexamples

LEX_SRC=src/scanner.l
LEX_C=lex.yy.c

BISON_SRC=src/parser.y
BISON_C=parser.tab.c

SRC_DIR = src
SRC_FILES = $(filter-out $(SRC_DIR)/main.c, $(wildcard $(SRC_DIR)/*.c))

BUILD_DIR = build
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC_FILES))
## ========================================================================== ##
$(ETAPA): $(OBJ_FILES) 
	gcc src/main.c $(LEX_C) $(BISON_C)  $(SRC_FILES)  -o $@  $(LFLAGS) $(CFLAGS)
	rm -f *.o

$(OBJ_FILES): $(LEX_SRC) $(LEX_C)   
	gcc -c $(LEX_C) $(BISON_C)  $(SRC_FILES) $(CFLAGS)

$(LEX_C): $(LEX_SRC)  src/parser.y  $(BISON_C) 
	flex $(LEX_SRC)

$(BISON_C): $(BISON_SRC) setup 
	bison $(BISON_FLAGS) $(BISON_SRC)

setup: clean 
	echo "Criando diretórios..."
	mkdir -p $(BUILD_DIR)
	mkdir -p $(SRC_DIR)

#==============================================================================


entrega: entrega_dir all 
	echo "Empacotando arquivos..."
	tar -cvzf entrega/$(ETAPA).tgz src include Makefile
	
entrega_dir: clean_entrega
	echo "Criando diretório de entrega..."
	mkdir -p entrega

clean_entrega:
	echo "Limpando diretório de entrega..."
	rm -rf entrega
#==============================================================================
clean:
	rm -f lex.yy.* etapa3 parser.tab.* etapa3.tgz *.o saida.dot grafo parser.output
all:
	make clean
	make etapa3