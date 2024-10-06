#!/bin/bash
make
# Objetivo eh criar testes automatizados de forma simples para a etapa01




echo "====== TESTE 01 ======================="
./etapa1 < testes/01.in > testes/01.out

if diff testes/01.out testes/01.res; then
    echo "Teste 01 passou"
else
    echo "Teste 01 falhou"
fi

echo "====== TESTE 02 ======================="
./etapa1 < testes/02.in > testes/02.out

if diff testes/02.out testes/02.res; then
    echo "Teste 02 passou"
else
    echo "Teste 02 falhou"
fi




echo "====== TESTE MAIUSCULO =============="
./etapa1 < testes/erros/maiusculo.in >  testes/erros/maiusculo.out


if diff testes/erros/maiusculo.out testes/erros/maiusculo.res; then
    echo "Teste maiusculo passou"
else
    echo "Teste maiusculo falhou"
fi

echo "====== TESTE FLOAT [0.] =============="
./etapa1 < testes/erros/float_incorreto.in >  testes/erros/float_incorreto.out

if diff testes/erros/float_incorreto.out testes/erros/float_incorreto.res; then
    echo "Teste FLOAT passou"
else
    echo "Teste FLOAT falhou"
fi

echo "====== TESTES SECAO 3.1 =============="
./etapa1 < testes/3_1.in > testes/3_1.out

if diff testes/3_1.out testes/3_1.res; then
    echo "Teste 3_1 passou"
else
    echo "Teste 3_1 falhou"
fi