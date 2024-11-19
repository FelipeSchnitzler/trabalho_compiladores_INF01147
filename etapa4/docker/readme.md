# ETAPA 2  

## DockerFile 

### Garanta que o ps docker ja esta rodando 
``` sudo systemctl start docker```
### Faca  o build da imagem
``` docker build -t etapa2_img . ```
### O mesmo para o container 
```docker run -it --name etapa2_container etapa2_img```

# Categoria de arquivos
## Arquivos source 
``` parser.y scanner.l main.c```

## Arquivos build 
``` parser.tab.h parser.tab.c lex.yy.c``` 