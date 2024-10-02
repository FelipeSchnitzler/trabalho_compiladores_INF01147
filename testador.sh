# Objetivo eh criar testes automatizados de forma simples para a etapa01


./etapa1 < testes/01.in > testes/01.out

if diff testes/01.out testes/01.res; then
    echo "Teste 01 passou"
else
    echo "Teste 01 falhou"
fi