FILES=$(ls -1 aval_*.tesh)
SEQ=1
for f in $FILES; do
    IDE=$(echo $f | sed -e 's/aval_//' -e 's/\.tesh//')
    foo=$(printf "%03d" $SEQ)
    echo $foo $IDE
    cp $f a${foo}.tesh
    cp entrada_${IDE} i${foo}
    sed -i "s/entrada_${IDE}/i${foo}/" a${foo}.tesh
    SEQ=$((SEQ+1))
done
