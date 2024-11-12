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
SRC_FILES := $(filter-out src/main.c, $(wildcard src/*.c))


$(ETAPA): middle  
	gcc src/main.c $(LEX_C) $(BISON_C)  $(SRC_FILES)  -o $@  $(LFLAGS) $(CFLAGS)
	rm -f *.o

middle: $(LEX_SRC) $(LEX_C)   
	gcc -c $(LEX_C) $(BISON_C)  $(SRC_FILES) $(CFLAGS)

$(LEX_C): $(LEX_SRC)  src/parser.y  $(BISON_C) 
	flex $(LEX_SRC)

$(BISON_C) : src/parser.y clean
	bison -d src/parser.y $(BISON_FLAGS)

#==============================================================================
entrega: entrega_dir all 
	echo "Empacotando arquivos..."
	tar -cvzf entrega/$(ETAPA).tgz $(LEX_SRC) parser.y main.c asd.c valor_lexico.c asd.h valor_lexico.h Makefile
	
entrega_dir: clean_entrega
	echo "Criando diretório de entrega..."
	mkdir -p entrega

clean_entrega:
	echo "Limpando diretório de entrega..."
	rm -rf entrega
#==============================================================================
clean:
	rm -f lex.yy.* etapa3 parser.tab.* etapa3.tgz *.o saida.dot
all:
	make clean
	make etapa3