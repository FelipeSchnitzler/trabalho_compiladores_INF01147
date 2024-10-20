

# bison -d parser.y
# flex scanner.l
# gcc -c lex.yy.c parser.tab.c
# gcc -o parser parser.tab.o lex.yy.o -ll

#------------------------------------------------------

# bison -d parser.y
# flex scanner.l
# gcc -c lex.yy.c parser.tab.c
# gcc -o parser lex.yy.o parser.tab.o -lfl
#------------------------------------------------------
UNAME_S := $(shell uname -s)
# Flags específicos para macOS e Linux
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl 
endif

etapa2: middle
	gcc main.c lex.yy.c parser.tab.c -o etapa2  $(LFLAGS)
middle: scanner.l lex.yy.c parser.y main.c parser.tab.c
	gcc -c lex.yy.c parser.tab.c
lex.yy.c: scanner.l parser.y parser.tab.c
	flex scanner.l
parser.tab.c: parser.y
	bison -d parser.y -Wcounterexamples

#==============================================================================
entrega: entrega_dir 
	echo "Empacotando arquivos..."
	tar -cvzf entrega/etapa2.tgz scanner.l parser.y main.c Makefile
entrega_dir: clean_entrega
	echo "Criando diretório de entrega..."
	mkdir -p entrega
clean_entrega:
	echo "Limpando diretório de entrega..."
	rm -rf entrega
#==============================================================================
clean:
	rm -f lex.yy.* etapa2 parser.tab.* etapa2.tgz
all:
	make clean
	make etapa2