# MacOS
## Flex 

If you need to have flex first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/flex/bin:$PATH"' >> /Users/lucascmachado/.zshrc

For compilers to find flex you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/flex/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/flex/include"

## Bison 
If you need to have bison first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/bison/bin:$PATH"' >> /Users/lucascmachado/.zshrc

For compilers to find bison you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/bison/lib"


## Command Line 
./etapa3 < tests/foo.ee ; dot saida.dot -Tpng -o grafo.png ; open grafo.png