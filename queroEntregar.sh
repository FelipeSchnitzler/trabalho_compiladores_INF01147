#!/bin/bash

ETAPA = "etapa1"

rm -f lex.yy.c "$ETAPA"  "$ETAPA".tgz
tar cvzf "$ETAPA.tgz" .

