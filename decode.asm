segment .data
intf db "%d", 10, 0


segment .text
global decode_data
extern printf

decode_data:
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
        push dword 0; syndrome
		push dword 0; temp syndrome
		push dword 0; data
		push dword 0; return value
    data_loop: cmp edi,  [ebp + 12 + 4 + 4 + 4]               ; edi <- nEncodedBytes
        je end_data_loop                                      ; if edi = -4 end the loop
        
		xor edx,edx;											; clear edx
		mov eax, [ebp + 8 + 4 + 4 + 4]						  ; eax <- encodedbytes pointer
		mov dl, byte[eax + edi]									; get current byte
		
		
		mov [ebp-12], edx;										; push current
		

		

		mov eax, 0; set eax 0
		mov dword[ebp -4 ],0; set syndrome 0
		
		
		traverse_column: cmp eax, 16					; compare eax 16
						je end_traverse_column			;  end traverse column
						mov edx, [ebp - 12]				; get value
						
						mov dword[ebp -8],0;			set temp sydrome 0
						mov esi, 112					; set esi 112
						traverse_row: cmp esi, -16		; compare esi -16
						je end_traverse_row				; end row traversing
						mov ebx, [ebp + 24 + 4 + 4 + 4] ; ebx <- H pointer
						add ebx, esi			; ebx <- ebx + esi (H+i)
						add ebx, eax			; ebx <- ebx + eax (H+i + j)
						mov ecx, [ebx]			; ecx <- H[i][j]
						
						and ecx, edx			; ecx <- ecx and edx (multip)
						xor ecx, [ebp-8]		; ecx <- ecx xor temp syndrome (addition)
						mov [ebp-8], ecx		; temp syndrome <- ecx
						shr edx,1				; edx <- edx >> 1, go for next bit of byte

						sub esi, 16				; esi <- esi -16
						
						jmp traverse_row 		; next row
						end_traverse_row:

						
							mov ebx, [ebp - 4]	; ebx <- sydrome
							shl ebx,1			; ebx <- ebx << 1 make place for the next bit of sydrome	
							or ebx, [ebp-8]		; ebx <- ebx or temp syndrome
							mov [ebp - 4],ebx	; sydrome <- ebx
							add eax, 4			; eax <- eax + 4
							jmp traverse_column	; next column
		end_traverse_column:
		
		; sydrome row
		mov edx, [ebp-4]						; get syndrome
		cmp edx, 0								; compare sydrome,0
		je no_error								; if sydrome is 0 there is no error 
		
		mov ecx, 112							; ecx <- 112	
		syndrome_traverse_row: cmp ecx,-16		;compare ecx, -16 see if it finished the wors
		je no_error								; if rows finished there is no error found go to no error
			mov edx, [ebp-4]					; get syndrome
			xor eax,eax							;clear eax	
			xor esi,esi							;clear esi
			syndrome_traverse_column: cmp esi, 16; compare esi, 16 see if it finished columns
				je end_syndrome_traverse_column		; if esi=16 jump end_sydrome_traverse column
				shl eax,1							; eax << 1 make place for the row value
				mov ebx, [ebp + 24 + 4 + 4 + 4]		; ebx <-  H pointer
				add ebx, ecx						; ebx <- ebx +ecx H+i
				add ebx, esi						; ebx <- ebx + esi H+i+j
				or eax, [ebx]						; eax <- eax or H[i][j]
				add esi,4							; esi <- esi +4
				jmp syndrome_traverse_column		; next column
			end_syndrome_traverse_column:	
				
				xor edx, eax						; edx <- edx xor eax (get difference)
				cmp edx, 0							; if differance is none found error
				je found_error						; if equal jumo found error

				sub ecx,16							;ecx <- ecx -16
				jmp syndrome_traverse_row			; next row
		
		
		no_error: mov ebx, 0			; ebx<-0 if no error write 0 to error status
		mov edx, [ebp -12]				;edx <- value
		jmp cont_data_loop				; cont to data loop
		
		;if there is error, error status = 10000000 >> found_row_number
		found_error: shr ecx, 4			; ecx >> 4 (ecx/16 = row number)
		mov ebx, 128					;ebx <- 10000000
		shr ebx, cl						; ebx<- ebx >> cl 
		mov eax, [ebp -16]				; eax <- error_count		
		add eax,1						; eax <- eax + 1 (error_count ++)	
		mov [ebp -16],eax				; error_count <- eax
		mov edx, [ebp -12]				;edx <- value
		xor edx, ebx											;error xor data


		cont_data_loop: 				;write the found error and go back to begining of the loop			

		mov eax, [ebp + 32 + 12]		;eax <- errorStatus
		mov byte[eax + edi], bl			;write error status to errorStatus[i]

		
		
		shr edx, 4												;edx <- edx >> 4, edx <- data

		mov ebx, edi											; ebx <- edi
		shr ebx, 1												; ebx <- ebx >> 1 (ebx divided by 2) 
		; 0th byte goes to 0 byte
		; 1th byte goes to 0 byte
		; 2th byte goes to 1 byte 
		; 3th byte goes to 1 byte soo i >> 1

		mov eax, [ebp + 16 + 4 + 4 + 4]							; eax <- decodedBytes
		xor ecx, ecx											; clear ecx
		mov cl, byte[eax + ebx]									; cl <-  decodedBytes[ebx]
		shl ecx, 4												; ecx<- ecx << 4 make room for new decodedData
		or ecx, edx												; ecx <- ecx | edx (make together data0 |data1)
		mov byte[eax + ebx], cl									; write to decodedBytes 


		add edi, 1						;increment edi (i++)
		
		jmp data_loop					; go next encodedData value

    end_data_loop:
		pop eax							;return value
		
		pop edx							; clear pushed values by popping
		pop edx							; clear pushed values by popping			
		pop edx							; clear pushed values by popping

        pop ebp                         ; restore ebp value
        pop esi                         ; restore esi value
        pop edi                         ; restore edi value
        pop ebx                         ; restore ebx value

    ret                             ; ret from function
