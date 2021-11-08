segment .data
intf db "%d", 10, 0


segment .text
global encode_data
extern printf

encode_data:
    push ebx                        ; save the old ebx
    push edi                        ; save the old edi
    push esi                        ; save the old esi
    push ebp                        ; save the old ebp

    mov  ebp,esp                    ; base pointer <- stack pointer
    
    xor edi,edi                     ; clear edi
    xor esi,esi                     ; clear esi
    xor eax, eax                    ; clear eax
    xor ebx, ebx                    ; clear ebx
    xor edx,edx                     ; clear edx
    
   
    mov edi, 0;
    ;stack
    ;   ebp <- ebp + 0
    ;   esi <- ebp + 4
    ;   edi <- ebp + 4 + 4
    ;   ebx <- ebp + 4 + 4 + 4
    ;   ret address <- ebp + 4 + 4 + 4 + 4
    ;   inputBytes pointer <- ebp + 8 + 4 + 4 + 4
    ;   nInputBytes <- ebp + 12 + 4 + 4 + 4
    ;   encodedBytes pointer <- ebp + 16 + 4 + 4 + 4
    ;   nEncodedBytes <- ebp + 20 + 4 + 4 + 4
    ;   H pointer <- ebp + 24 + 4 + 4 + 4
    ;   Hmr pointer <- ebp + 28 + 4 + 4 + 4


    big_loop: cmp edi,  [ebp + 12 + 4 + 4 + 4]               ; loop goes on edi-0 nInoutBytes
        je end_loop_big                                      ; if edi = -4 end the loop
        mov esi,1                                            ; esi <- 1 (counter for datas in byte first and second)
        byte_tara: cmp esi, -1                               ; compare esi with 1
            je end_byte_tara                                 ; end byte tara
                mov edx, [ebp +8 +4 + 4 +4]  ; edx <- argument 2 (inputBytes pointer)
                
                add edx, edi                ; edx <- inputBytes + byte counter
               
                xor ebx,ebx                 ; clear ebx        
                mov bl, byte[edx]           ; bl <- data in inputBytes + bytecounter
                 
                mov ecx, esi                ; ecx <- esi  (to use in shift operation)
                shl ecx, 2                  ; ecx = ecx*4         
                shr ebx,cl                  ; ebx <- ebx >> ecx (shift the input bytes)
                and ebx, 15                 ; ebx <- ebx & 1111 (get the lowest 4 bit) current word
                push dword ebx              ; push the current word to stack this will become [w|p] (encoded data)
                
            
                xor eax,eax                 ; clear eax
                xor ebx, ebx                ; clear ebx
                xor ecx, ecx                ; clear ecx
                xor edx,edx                 ; clear edx
                

            loop: cmp eax,16                ; compare eax 16 (traverse columns)
                je end_loop                 ; if zflag = 0 jump end loop

                    
                push dword 0                ; push 0 (will hold word * Hmr ith column = p[i])
                

                mov edx, [ebp +8 +4 + 4 +4] ; edx <- argument 2 (inputBytes pointer)
                ;mov edx, [edx]             ; edx<- input bytes content 
                add edx, edi                ; edx <- inputBytes + byte counter
                xor ebx,ebx                 ; clear ebx        
                mov bl, byte[edx]           ; bl <- data in inputBytes + bytecounter
                
                mov ecx, esi                ;ecx <- esi  (to use in shift operation)
                shl ecx, 2                  ; mul 4          
                shr ebx,cl                  ; edx <- edx >> ecx (shift the input bytes)
                and ebx, 15                 ; edx <- edx & 1111 (get the lowest 4 bit) current word

                mov edx,ebx

                

                mov  ecx,[ebp+28+4+4+4]     ; ecx <- Hmr pointer
            
                ;word[3] * Hmr[3][i] 
                ;Not: indexes from lefthand side starting from 0

                mov ebx, [ecx + eax + 48 ]  ; ebx<- Hmr[3][i]

                and ebx, edx                ; ebx <- ebx & edx (Hmr[3][i] & word[3])
                xor ebx, [ebp - 8]          ; ebx <- ebx xor p[i] 
                mov [ebp-8], ebx            ; p[i] <- ebx
                
            
                
                mov ebx, [ecx + eax + 32]   ; ebx<- Hmr[2][i]

                shr edx,1                   ; edx <- edx >> 1 (word <- current word >> 1)
                and ebx, edx                ; ebx <- ebx & edx (Hmr[2][i] & word[2])

                xor ebx, [ebp-8]            ; ebx <- ebx xor p[i]
                mov [ebp-8], ebx            ; p[i] <- ebx

                
                mov ebx, [ecx + eax + 16]   ; ebx<- Hmr[1][i]
                
                shr edx,1                   ; edx <- edx >> 1 (word <- current word >> 1)
                
                and ebx, edx                ; ebx <- ebx & edx (Hmr[1][i] & word[1])

                xor ebx, [ebp-8]            ; ebx <- ebx xor p[i]
                mov [ebp-8], ebx            ; p[i] <- ebx

                mov ebx, [ecx + eax + 0 ]   ; ebx<- Hmr[0][i]
                shr edx,1                    ; edx <- edx >> 1 (word <- current word >> 1)
                and ebx, edx                ; ebx <- ebx & edx (Hmr[1][i] & word[1])

                xor ebx, [ebp-8]            ; ebx <- ebx xor p[i]
                mov [ebp-8], ebx            ; p[i] <- ebx
                

                pop edx;                    ; pop p[i]
                mov ebx, [ebp -4]           ; ebx <- current encoded
                
                shl ebx,1                   ; ebx <- ebx << 1 (shift current encoded to add p[i])
                

                or edx, ebx                 ; edx <- edx | ebx (current encoded | p[i])
                mov [ebp - 4], edx          ; encoded <- current encoded
                
                
                add eax,4                   ; eax <- eax + 4 (increment)
                
            
                jmp loop;                   ; jump begining of the loop

            end_loop:
                
                
                

                pop edx                     ; pop encoded
                mov eax, [ebp + 16 +4+4+4]  ; eax <- encodedData pointer
                mov ebx, edi                ; ebx <- edi (byte counter)
                shl ebx,1                   ; byte counter *2
                add ebx,1                   ; byte counter * 2 +1      
                sub ebx, esi                ; byte counter *2 +1 - esi
                add eax, ebx                ; encodedData + byte counter *2 +1 - esi (the place I will write the result)         
                
    
                mov byte[eax],dl            ; encodedData[i] <- encoded (byte)
                sub esi,1                   ; esi <- esi + 1 (increment esi)
                jmp byte_tara               ; go to next 4 bit in byte
                 
        end_byte_tara:
                
                add edi,1                   ; increment edi (byte counter)
                jmp big_loop                ; jump begining of the loop     
            
    end_loop_big:
    
        pop ebp                         ; pop ebp
        pop esi                         ; pop esi
        pop edi                         ; pop edi
        pop ebx                         ; pop ebx
    ret                             ; ret from function
