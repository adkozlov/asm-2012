extern calloc
extern free
extern printf

section .data
	format_int db "%d", 10, 0
	format_double db "%f", 10, 0
	format_complex db "%f + %fi", 10, 0

section .text

calloc_int_size:
	push 4 ; sizeof(int)
	push dword [ebp + 12] ; size
	call calloc
	add esp, 8
	ret

calloc_double_2size:
	push 8 ; sizeof(double)
	push dword [ebp + 12] ; size
	shl dword [esp], 1
	call calloc
	add esp, 8
	ret

global fft

; double* fft(const double *in_data, const int size)
fft:
	push ebp
	mov ebp, esp
	sub esp, 36 ; todo: local vars
	push ebx
	push esi
	push edi	
	
	xor ecx, ecx ; int k = 0
	dec ecx
	log_loop: ; while ((1 << k) < size)
		inc ecx
	
		; (1 << k) < size
		xor eax, eax
		inc eax
		shl eax, cl
		
		cmp eax, [ebp + 12]
		jb log_loop				
	mov dword [ebp - 4], ecx		

	; int *rev = (int*) calloc(size, sizeof(int))
	call calloc_int_size
	mov [ebp - 8], eax
	
	mov edx, [ebp - 8]
	mov dword [edx], 0 ; rev[0] = 0	
	mov dword [ebp - 16], -1 ; int high1 = -1
	
	xor ecx, ecx
	inc ecx
	rev_loop: ; for (i = 1; i < size; ++i)		
		; if (i & (i - 1) == 0)
		mov eax, ecx
		dec eax
		test eax, ecx
		jnz .false
			inc dword [ebp - 16]
		.false:
		
		; i ^ (1 << high1)
		xor eax, eax
		inc eax 
		push ecx
		mov ecx, dword [ebp - 16]
		shl eax, cl
		pop ecx
		xor eax, ecx
		
		mov edx, [ebp - 8]
		mov ebx, [edx + 4 * eax]
		mov dword [edx + 4 * ecx], ebx
	
		; 1 << (k - high1 - 1)
		mov edx, dword [ebp - 4]
		sub edx, dword [ebp - 16]
		dec edx
		xor eax, eax
		inc eax
		push ecx
		mov ecx, edx
		shl eax, cl
		pop ecx		
		
		mov edx, [ebp - 8]
		xor dword [edx + 4 * ecx], eax
		
		inc ecx
		cmp ecx, [ebp + 12]
		jb rev_loop

	; double *roots = (double*) calloc(2 * size, sizeof(double))
	call calloc_double_2size
	mov [ebp - 20], eax

	; double alpha = 2 * M_PI / size
	fldpi
	push 2
	fimul dword [esp]
	add esp, 4
	fidiv dword [ebp + 12]	

	; for (i = 0; i < size; ++i)
	xor ecx, ecx
	roots_loop:
		fld st0
		push ecx
		fimul dword [esp]
		pop ecx
		fsincos		
		
		mov eax, ecx
		shl eax, 1
		mov edx, [ebp - 20]
		fstp qword [edx + 8 * eax]
		fstp qword [edx + 8 * eax + 8]

		inc ecx
		cmp ecx, [ebp + 12]
		jb roots_loop

	; double *cur = (double*) calloc(2 * size, sizeof(double));
	call calloc_double_2size
	mov [ebp - 24], eax	
	
	; for (i = 0; i < size; ++i)
	xor ecx, ecx
	cur_loop:
		; int ni = rev[i]
		mov edx, [ebp - 8]
		mov ebx, [edx + 4 * ecx]
		
		shl ebx, 1		
		mov edx, [ebp + 8]
		movsd xmm0, [edx + 8 * ebx]
		movsd xmm1, [edx + 8 * ebx + 8]
		
		shl ecx, 1
		mov edx, [ebp - 24]
		movsd [edx + 8 * ecx], xmm0
		movsd [edx + 8 * ecx + 8], xmm1
		shr ecx, 1
		
		push ecx
		push ecx
		push format_int
		call printf
		add esp, 8
		pop ecx					
		
		inc ecx
		cmp ecx, [ebp + 12]
		jb cur_loop

	; free(rev)
	push dword [ebp - 8]
	call free
	add esp, 4
	
	; for (len = 1; len < size; len <<= 1)
	xor ecx, ecx
	inc ecx
	len_loop:
		; double *ncur = (double*) calloc(2 * size, sizeof(double))
		push ecx
		call calloc_double_2size
		mov [ebp - 28], eax
		pop ecx
		
		mov eax, dword [ebp + 12]
		shr eax, cl
		
		xor edx, edx
		p1_loop:
			xor ebx, ebx
			i_loop:
				mov esi, eax
				imul esi, ebx
				shl esi, 1
				
				mov edi, [ebp - 20]
				movsd xmm2, [edi + 8 * esi]
				movsd xmm3, [edi + 8 * esi + 8]
				
				mov esi, edx
				add esi, ecx
				shl esi, 1
				
				mov edi, [ebp - 24]
				movsd xmm4, [edi + 8 * esi]
				movsd xmm5, [edi + 8 * esi + 8]
				
				movsd xmm6, xmm2
				mulsd xmm6, xmm4
				movsd xmm7, xmm1
				mulsd xmm7, xmm5
				movsd xmm0, xmm6
				subsd xmm0, xmm7
				
				movsd xmm6, xmm2
				mulsd xmm6, xmm5
				movsd xmm7, xmm1
				mulsd xmm7, xmm4
				movsd xmm0, xmm6
				subsd xmm0, xmm7
			
				mov esi, edx
				shl esi, 1
				
				mov edi, [ebp - 24]
				movsd xmm2, [edi + 8 * esi]
				movsd xmm3, [edi + 8 * esi + 8]
				
				movsd xmm4, xmm2
				addsd xmm4, xmm0
				movsd xmm5, xmm3
				addsd xmm5, xmm1
				
				mov edi, [ebp - 28]
				movlpd [edi + 8 * esi], xmm4
				movlpd [edi + 8 * esi + 8], xmm5
				
				movsd xmm4, xmm2
				subsd xmm4, xmm0
				movsd xmm5, xmm3
				subsd xmm5, xmm1
				
				shl ecx, 1
				add esi, ecx
				
				movlpd [edi + 8 * esi], xmm4
				movlpd [edi + 8 * esi + 8], xmm5
				
				shr ecx, 1
					
								
				inc ebx
				inc edx
				cmp ebx, ecx
				jb i_loop
			
			
			add edx, ecx
			cmp edx, [ebp + 12]
			jb p1_loop
		
		; free(ncur)
		push ecx
		push dword [ebp - 24]
		call free
		add esp, 4
		pop ecx
		
		mov edx, [ebp - 28]
		mov [ebp - 24], edx
		
		shl ecx, 1
		cmp ecx, [ebp + 12]
		jb len_loop

	; free(roots)
	push dword [ebp - 20]
	call free
	add esp, 4

	; return cur;
	mov eax, [ebp - 24]

	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret
	
global fft_rev	
	
; double* fft_rev(const double *in_data, const int size)
fft_rev:
	push ebp
	mov ebp, esp
	sub esp, 4
	push ebx
	push esi
	push edi

	; double *cur = fft(in_data, size)
	push dword [ebp + 12]
	push dword [ebp + 8]
	call fft
	add esp, 8	
	mov [ebp - 4], eax
	
	cvtsi2sd xmm0, [ebp + 12]
	
	xor ecx, ecx
	size_loop: ; for (i = 0; i < 2 * size; ++i)
		mov edx, [ebp - 4]
		movsd xmm1, [edx + 8 * ecx]
		divsd xmm1, xmm0
		movsd [edx + 8 * ecx], xmm1
		
		mov edx, dword [ebp + 12]
		shl edx, 1
		
		inc ecx
		cmp ecx, edx
		jb size_loop
	
	mov ecx, 2
	reverse_loop: ; for (i = 1; i < size / 2; ++i)
		mov edx, [ebp - 4]
		movsd xmm0, [edx + 8 * ecx]
		movsd xmm1, [edx + 8 * ecx + 8]
		
		; int i_rev = size - i
		mov ebx, [ebp + 12]
		shl ebx, 1
		sub ebx, ecx
		
		movsd xmm2, [edx + 8 * ebx]
		movsd xmm3, [edx + 8 * ebx + 8]

		movsd [edx + 8 * ebx], xmm0
		movsd [edx + 8 * ecx + 8], xmm1
		movsd [edx + 8 * ecx], xmm2
		movsd [edx + 8 * ecx + 8], xmm3

		add ecx, 2
		cmp ecx, dword [ebp + 12]
		jb reverse_loop
		
	
	; return cur;
	mov eax, [ebp - 4]	

	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret
