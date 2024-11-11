UNAME_S := $(shell uname -s)
# Flags específicos para macOS e Linux
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl 
endif

etapa3: middle
	gcc main.c lex.yy.c parser.tab.c asd.c valor_lexico.c -o etapa3  $(LFLAGS)
	rm -f *.o

middle: scanner.l lex.yy.c parser.y main.c parser.tab.c asd.c valor_lexico.c 
	gcc -c lex.yy.c parser.tab.c asd.c valor_lexico.c 

lex.yy.c: scanner.l parser.y parser.tab.c
	flex scanner.l

parser.tab.c: parser.y
	bison -d parser.y -Wcounterexamples

#==============================================================================
entrega: entrega_dir all 
	echo "Empacotando arquivos..."
	tar -cvzf entrega/etapa3.tgz scanner.l parser.y main.c asd.c valor_lexico.c asd.h valor_lexico.h Makefile
	
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