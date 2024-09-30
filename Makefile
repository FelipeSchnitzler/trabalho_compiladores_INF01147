CC = gcc
CFLAGS = -Wall -g

# Project files
SRC = $(wildcard src/*.c)
OBJ = $(patsubst src/%.c, build/%.o, $(SRC))

all: clean compile

# Create directories
bin:
	mkdir -p bin

build:
	mkdir -p build

# Compile `.c` to `.o`
build/%.o: src/%.c | build
	@echo "Compiling $<"
	$(CC) $(CFLAGS) -c $< -o $@

# Compile `.o` to binary
bin/server: $(OBJ) | bin
	$(CC) -o bin/main $(OBJ)

.PHONY: compile clean test

compile: bin/server

test: CFLAGS += -DTEST_MODE
test: clean compile 
	./bin/server

clean:
	rm -rf build/* bin/*
