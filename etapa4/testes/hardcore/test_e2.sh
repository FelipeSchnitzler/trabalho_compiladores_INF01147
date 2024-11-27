FILES=$(ls ../E2 -1 asl???)
SEQ=1
for f in $FILES; do

    # Lê a primeira linha do arquivo
    first_line=$(head -n 1 "$f")
    echo "$f $first_line"
done
