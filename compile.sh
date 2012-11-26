#!/bin/bash

yasm ./src/fft.asm -o ./bin/fft.o -f elf32
echo "asm compiling success"

gcc -c ./src/main.c -o ./bin/main.o
echo "c compiling success"

ld -o ./bin/fft --dynamic-linker /lib/ld-linux.so.2 -melf_i386 -lc ./bin/main.o ./bin/fft.o
echo "linking success"

./bin/fft
echo "run sucess"
