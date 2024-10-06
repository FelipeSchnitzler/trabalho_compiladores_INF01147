#!/bin/bash

if [ -d "testes" ]; then
  # Apaga o diretório /testes e todo o seu conteúdo
  rm -rf testes/
  echo "Diretório [testes] deletado com sucesso."
else
  echo "Diretório /testes não existe."
fi


if [ -d "querotestar.sh " ]; then
  # Apaga o diretório /testes e todo o seu conteúdo
  rm -f  querotestar.sh 
  echo "===== [querotestar.sh]  DELETADO com sucesso."
else
  echo "[querotestar.sh]  NAO existe."
fi

Echo "======= Clonando repositório de testes ====================="
sleep 3 


if [ -d "Compiladores" ]; then
  # Apaga o diretório /testes e todo o seu conteúdo
  rm -rf Compiladores/
  echo "Diretório [Compiladores] deletado com sucesso."
else
  echo "[Compiladores.sh]  NAO existe."
fi

git clone https://github.com/lcmachado16/Compiladores.git

mv Compiladores/etapa1/testes/ .
mv Compiladores/etapa1/queroTestar.sh .

Echo "======= Movendo os Testes para diretorio atual ====================="
rm -rf Compiladores/

Echo "======= Autorizando execucao queroTestar.sh ====================="
chmod +x queroTestar.sh

Echo "======= Operacao Realizada com sucesso! ====================="
