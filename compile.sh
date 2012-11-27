#!/bin/bash

yasm ./src/fft.asm -f elf32 -o ./bin/fft.o
gcc -c ./src/main.c -o ./bin/main.o

#ld --dynamic-linker /lib/ld-linux.so.2 -melf_i386 -lc -o ./bin/fft ./bin/main.o ./bin/fft.o
gcc -o ./bin/main.c ./bin/fft.o -m32

./bin/fft
