# Objetivo eh criar testes automatizados de forma simples para a etapa01


./etapa1 < testes/01.in > testes/01.out

if diff testes/01.out testes/01.res; then
    echo "Teste 01 passou"
else
    echo "Teste 01 falhou"
fi


./etapa1 < testes/erros/maiusculo.in >  testes/erros/maiusculo.out

if diff testes/erros/maiusculo.out testes/erros/maiusculo.res; then
    echo "Teste maiusculo passou"
else
    echo "Teste maiusculo falhou"
fi