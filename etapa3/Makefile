UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)  # macOS
    LFLAGS = -ll  
else ifeq ($(UNAME_S), Linux)  # Linux
    LFLAGS = -lfl 
endif

## ==============================================================================
ETAPA = etapa3
## ==============================================================================
CC = gcc
CFLAGS = -Iinclude
BISON_FLAGS = -d -v -Wcounterexamples

LEX_SRC = src/scanner.l
LEX_C = $(BUILD_DIR)/lex.yy.c

BISON_SRC = src/parser.y
BISON_C = $(BUILD_DIR)/parser.tab.c
BISON_H = $(BUILD_DIR)/parser.tab.h

SRC_DIR = src
BUILD_DIR = build
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC_FILES))

 
$(ETAPA): $(OBJ_FILES) $(LEX_C) $(BISON_C)
	$(CC) $(OBJ_FILES) $(LEX_C) $(BISON_C) -o $@ $(LFLAGS) $(CFLAGS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) -c $< -o $@ $(CFLAGS)

$(LEX_C): $(LEX_SRC) | $(BUILD_DIR)
	flex -o $@ $<

$(BISON_C) $(BISON_H): $(BISON_SRC) | $(BUILD_DIR)
	bison $(BISON_FLAGS) -o $(BISON_C) $<

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(ETAPA)

png: 
	mkdir -p outputs
	dot saida.dot -Tpng -o outputs/grafo.png
	xdg-open outputs/grafo.png

.PHONY: clean
