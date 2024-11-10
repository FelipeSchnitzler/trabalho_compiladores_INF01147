# MacOS
If you need to have bison first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/bison/bin:$PATH"' >> /Users/lucascmachado/.zshrc

For compilers to find bison you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/bison/lib"
