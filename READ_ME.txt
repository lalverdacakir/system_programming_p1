for encode.asm:
nasm -f elf32 encode.asm -o encode.o

for decode asm:
nasm -f elf32 decode.asm -o decode.o

for c file:
gcc -c main_skeleton.c -o main.o

for binding:
gcc decode.o encode.o main.o -o main

for run:
./main <input bytes file name> <input matrix file name>