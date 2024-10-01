etapa1: scanner.l lex.yy.c main.c tokens.h
	gcc main.c lex.yy.c -o etapa1 -lfl -v
lex.yy.c: scanner.l
	flex scanner.l