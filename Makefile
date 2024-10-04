UNAME_S := $(shell uname -s)
# Flags específicos para macOS e Linux
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl 
endif

etapa1: scanner.l lex.yy.c main.c tokens.h
	gcc main.c lex.yy.c -o etapa1 $(LFLAGS)
lex.yy.c: scanner.l
	flex scanner.l

clean:
	rm -f lex.yy.c etapa1

teste: 
	./etapa1 < testes/01.in < testes/01.out
	./etapa1 < testes/02.in < testes/02.out

all:
	make clean
	make etapa1