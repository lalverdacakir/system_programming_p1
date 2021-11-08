# system_programming_p1
System Programming Project 1

ITU Computer Enginnering System Programming Course 
Project 1

Encoder and Decoder for Hamming code is implemented.

Compile the assembly files:

encode.asm:           nasm -f elf32 encode.asm -o encode.o

decode asm:           nasm -f elf32 decode.asm -o decode.o

Compile the c file:   gcc -c main_skeleton.c -o main.o

Link the files:       gcc decode.o encode.o main.o -o main

for run:              ./main <input bytes file name> <input matrix file name>
