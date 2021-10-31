segment .data
intf db "%d", 10, 0


segment .text
global encode_data
extern printf

encode_data:
    push ebx                        ;
    push edi                        ; save the old di value
    push esi                        ;
    push ebp                        ; save the old base pointer value

    mov  ebp,esp                    ; base pointer <- stack pointer
    
    xor edi,edi                     ; clear edi
    xor esi,esi                     ; clear esi
    xor eax, eax                    ; clear eax
    xor ebx, ebx                    ; clear ebx
    xor edx,edx                     ; clear edx
    
   
    mov edi, [ebp + 12 + 4 + 4 + 4] ; edi<-nInputBytes
    shl edi, 3                      ; edi <- edi * 8 (8*nInoutBytes)
    sub edi, 4                      ; edi <- edi -4 (8*nInputBytes - 4)
    

big_loop: cmp edi, -4; loop goes on edi-0
    je end_loop_big; if edi = -4 end the loop

        mov edx, [ebp +8 +4 + 4 +4] ; argument 2 (inputBytes pointer)
        mov edx, [edx]              ; edx<- input bytes content 
       

        mov ecx, edi                ; ecx <- edi  (to use in shift operation)
        shr edx,cl                  ; edx <- edx >> ecx (shift the input bytes)
        and edx, 15                 ; <- edx <- edx & 1111 (get the lowest 4 bit) current word
        push dword edx              ; push the current word to stack
       

    
    
        xor eax,eax                 ; clear eax
        xor ebx, ebx                ; clear ebx
        xor ecx, ecx                ; clear ecx
        xor edx,edx                 ; clear edx
        

    loop: cmp eax,16; compare eax 16 (traverse columns)
        je end_loop ; if zflag = 0 jump end loop

        
        
        ;xor edx,edx; clear edx
        push dword 0; push 0 (will hold word * current column)

        mov edx, [ebp +8 +4+4+4]; edx <- inputBytes pointer
        mov edx, [edx];edx <- content inputBytes
       
        mov ecx, edi; ecx <- edi for shift
        shr edx,cl; edx <- edx >> cl
       
        and edx,15; edx <- edx &1111 (lowest 4 bits)
        
        mov  ecx,[ebp+28+4+4+4] ;ecx <- Hmr pointer

       
       
        mov ebx, [ecx + eax + 48 ]; ebx<- Hmr[i][3]

        and ebx, edx; Hmr[i][3] & word

        xor ebx, [ebp - 8];
        mov [ebp-8], ebx;
        
        
        
        
        mov ebx, [ecx + eax + 32]; point edilen yer

        shr edx,1;
        and ebx, edx;

        xor ebx, [ebp-8];
        mov [ebp-8], ebx;

        
        mov ebx, [ecx + eax + 16]; point edilen yer
        
        shr edx,1;
        
        and ebx, edx;

        xor ebx, [ebp-8];
        mov [ebp-8], ebx;

        mov ebx, [ecx + eax + 0 ]; point edilen yer
        shr edx,1;
        and ebx, edx;

        xor ebx, [ebp-8];
        mov [ebp-8], ebx;
        

        pop edx;
        mov ebx, [ebp -4];
        
        shl ebx,1
        

        or edx, ebx;
        mov [ebp - 4], edx;

        
        add eax,4;
        
    
        jmp loop;

    end_loop:
        sub edi, 4;
        

        pop edx;
        mov eax, [ebp + 16 +4+4+4];encodedData pointer
        mov byte[eax + esi],0;
        mov byte[eax + esi],dl;

        add esp, 8;
        add esi,1;
        jmp big_loop;
        
end_loop_big:
    
    pop ebp ; fonksitondan çıkarken
    pop esi;
    pop edi;
    pop ebx;
    ret
