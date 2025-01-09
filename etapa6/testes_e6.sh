#!/bin/bash

# Diretório de entrada e saída
INPUT_DIR="/home/lucascmachado/Downloads/e6_all/E6"
OUTPUT_DIR="outputs"
OUTPUT_CSV="${OUTPUT_DIR}/outputs.csv"

# Cria o diretório de saída, se necessário
mkdir -p "$OUTPUT_DIR"

# Limpa o arquivo CSV existente ou cria um novo
echo "Arquivo, Código de Saída" > "$OUTPUT_CSV"

# Loop para processar os arquivos kwj00 a kwj20
for i in $(seq -w 0 22); do
    INPUT_FILE="${INPUT_DIR}/kwj${i}"

    # Verifica se o arquivo de entrada existe
    if [[ -f "$INPUT_FILE" ]]; then
        # Executa o pipeline de comandos
        ./etapa6 < "$INPUT_FILE" > etapa6.s
        gcc -o etapa6_asm etapa6.s
        ./etapa6_asm
        EXIT_CODE=$?

        # Adiciona o resultado ao CSV
        echo "kwj${i}, ${EXIT_CODE}" >> "$OUTPUT_CSV"
    else
        echo "Aviso: Arquivo $INPUT_FILE não encontrado. Pulando..."
    fi
done

echo "Teste concluído. Resultados salvos em $OUTPUT_CSV."
