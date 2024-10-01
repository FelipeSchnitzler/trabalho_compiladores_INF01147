UNAME_S := $(shell uname -s)
# Flags específicos para macOS e Linux
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  # No need for -lfl in macOS, use -ll for Flex library
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl  # Use -lfl in Linux for Flex library
endif

etapa1: scanner.l lex.yy.c main.c tokens.h
	gcc main.c lex.yy.c -o etapa1 $(LFLAGS)
lex.yy.c: scanner.l
	flex scanner.l