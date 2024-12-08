FROM debian:testing

RUN apt-get -y update


RUN apt-get -y install build-essential make gcc gdb flex bison valgrind vim git 
RUN useradd -s /bin/bash --create-home user
USER user
WORKDIR /home/user

RUN git clone https://github.com/FelipeSchnitzler/trabalho_compiladores_INF01147.git
WORKDIR /home/user/trabalho_compiladores_INF01147