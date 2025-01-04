FILES=$(ls -1 asl???)
SEQ=1
for f in $FILES; do
    foo=$(printf "%03d" $SEQ)    
    git mv $f qwe${foo}
    SEQ=$((SEQ+1))
done
