#!/bin/bash

git add ./src/fft.asm
git add ./src/main.c
git add compile.sh

git commit -m "$1"
git push
