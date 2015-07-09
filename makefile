CC = gcc
FILES = game.c conway.h conway.s
OUT_EXE = game
FLAGS =  -Wall -ansi -pedantic -m32

build: $(FILES)
	$(CC) $(FLAGS) -o $(OUT_EXE) $(FILES)

clean:
	rm -f *.o core

rebuild: clean build