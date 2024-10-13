

# bison -d parser.y
# flex scanner.l
# gcc -c lex.yy.c parser.tab.c
# gcc -o parser parser.tab.o lex.yy.o -ll
UNAME_S := $(shell uname -s)
# Flags específicos para macOS e Linux
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl 
endif

etapa2: scanner.l lex.yy.c parser.y main.c parser.tab.c
	gcc main.c lex.yy.c parser.tab.c -o etapa2  $(LFLAGS)
lex.yy.c: scanner.l parser.y parser.tab.c
	flex scanner.l
parser.tab.c: parser.y
	bison -d parser.y -Wcounterexamples


clean:
	rm -f lex.yy.c etapa2 parser.tab.*
all:
	make clean
	make etapa2