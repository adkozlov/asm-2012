extern calloc
extern free
extern printf

section .data
	format_int db "%d", 10, 0
	format_double db "%f", 10, 0

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
	mov ecx, [ebp + 12]
	roots_loop:
		dec	ecx

		fld st0
		push ecx
		fimul dword [esp]
		pop ecx
		fsincos		
		
		mov eax, ecx
		shl eax, 1
		mov edx, [ebp - 20]
		fstp qword [edx + 8 * eax]
		inc eax
		fstp qword [edx + 8 * eax]

		cmp ecx, 0
		jnz roots_loop

	; double *cur = (double*) calloc(2 * size, sizeof(double));
	call calloc_double_2size
	mov [ebp - 24], eax
	
	xor ecx, ecx
	a_loop:
		push ecx
		
		push edx, [ebp - 8]
		push dword [edx + 4 * ecx]
		push format_int
		call printf
		add esp, 8
		
		pop ecx
		
		inc ecx
		cmp ecx, [ebp + 12]
		jb a_loop
	
	; for (i = 0; i < size; ++i)
	mov ecx, [ebp + 12]
	cur_loop:
		dec ecx
		
		; int ni = rev[i]
		mov edx, [ebp - 8]
		mov ebx, [edx + 4 * ecx]
		shl ebx, 1
		
		push ecx
		push ebx
		push format_int
		call printf
		add esp, 8
		pop ecx
		
		lea eax, [2 * ecx]

		mov edx, [ebp + 8]
		mov esi, [edx + 8 * ebx]
		mov edi, [edx + 8 * ebx + 4]
		mov edx, [ebp - 24]
		mov [edx + 8 * eax], esi
		mov [edx + 8 * eax + 4], edi

		inc ebx

		mov edx, [ebp + 8]
		mov esi, [edx + 8 * ebx]
		mov edi, [edx + 8 * ebx + 4]
		mov edx, [ebp - 24]
		mov [edx + 8 * eax], esi
		mov [edx + 8 * eax + 4], edi					
		
		cmp ecx, 0
		jnz cur_loop

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
		pdest_loop:
			xor ebx, ebx
			i_loop:
						
				
				inc ebx
				inc edx
				cmp ebx, ecx
				jb i_loop
			
			
			add edx, ecx
			cmp edx, [ebp + 12]
			jb pdest_loop
		
		; free(ncur)
		push ecx
		push dword [ebp - 28]
		call free
		add esp, 4
		pop ecx
		
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
