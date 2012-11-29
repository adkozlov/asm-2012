#!/bin/bash

yasm ./src/fft.asm -f elf32 -o ./bin/fft.o
gcc -c ./src/main.c -o ./bin/main.o -m32

gcc ./bin/main.o ./bin/fft.o -m32 -o fft
./fft

cat fft.out
