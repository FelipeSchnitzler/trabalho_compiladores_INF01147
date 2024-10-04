#!/bin/bash

rm -f lex.yy.c etapa1  etapa1.tgz 
# tar cvzf etapa1.tgz --exclude='./docs' --exclude='./testes'  --exclude='./quero*'  .

tar cvzf etapa1.tgz --exclude='.*'   scanner.l main.c tokens.h Makefile 'testes' quero*

