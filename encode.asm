
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
    
   
    mov edi, [ebp + 12 + 4 + 4 + 4] ; edi<-nInputBytes
    shl edi, 3                      ; edi <- edi * 8 (8*nInoutBytes)
    sub edi, 4                      ; edi <- edi -4 (8*nInputBytes - 4)
        

    big_loop: cmp edi, -4               ; loop goes on edi-0
        je end_loop_big                 ; if edi = -4 end the loop

            mov edx, [ebp +8 +4 + 4 +4] ; edx <- argument 2 (inputBytes pointer)
            mov edx, [edx]              ; edx<- input bytes content 
        

            mov ecx, edi                ; ecx <- edi  (to use in shift operation)
            shr edx,cl                  ; edx <- edx >> ecx (shift the input bytes)
            and edx, 15                 ; edx <- edx & 1111 (get the lowest 4 bit) current word
            push dword edx              ; push the current word to stack this will become [w|p] (encoded data)
        

        
        
            xor eax,eax                 ; clear eax
            xor ebx, ebx                ; clear ebx
            xor ecx, ecx                ; clear ecx
            xor edx,edx                 ; clear edx
            

        loop: cmp eax,16; compare eax 16 (traverse columns)
            je end_loop ; if zflag = 0 jump end loop

                
            push dword 0                ; push 0 (will hold word * Hmr ith column = p[i])

            mov edx, [ebp +8 +4+4+4]    ; edx <- argument 2 (inputBytes pointer) 
            mov edx, [edx]              ; edx <- inputBytes content
            mov ecx, edi                ; ecx <- edi  (to use in shift operation)
            shr edx,cl                  ; edx <- edx >> ecx (shift the input bytes)
            and edx,15                  ; edx <- edx & 1111 (get the lowest 4 bit) current word
                                        ; line above (edx) word <- currenet word

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
            
            sub edi, 4                  ; edi <- edi -4
            

            pop edx                     ; pop encoded
            mov eax, [ebp + 16 +4+4+4]  ; eax <- encodedData pointer
            mov byte[eax + esi],dl      ; encodedData[i] <- encoded (byte)
            add esi,1                   ; esi <- esi + 1 (increment esi)
            jmp big_loop                ; jump begining of the loop       
            
    end_loop_big:
    
        pop ebp                         ; pop ebp
        pop esi                         ; pop esi
        pop edi                         ; pop edi
        pop ebx                         ; pop ebx
    ret                             ; ret from function
