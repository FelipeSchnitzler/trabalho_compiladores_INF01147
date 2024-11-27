
TARGET = test_table

SRCS = table.c main.c

CC = gcc
CFLAGS = -Wall -Wextra -g


$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f $(TARGET)
