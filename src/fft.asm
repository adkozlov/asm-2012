extern calloc
extern free

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
	sub esp, 32 ; todo: local vars
	push ebx
	push esi
	push edi	
	
	xor ecx, ecx ; int k = 0
	log_loop: ; while ((1 << k) < size)
		; (1 << k) < size
		xor eax, eax
		inc eax
		shl eax, cl
		inc ecx
		cmp eax, [ebp + 12]
		jb log_loop
	mov dword [ebp - 16], ecx

	; int *rev = (int*) calloc(size, sizeof(int))
	call calloc_int_size
	mov [ebp - 20], eax
	
	mov dword [ebp - 20], 0 ; rev[0] = 0
	mov dword [ebp - 24], -1 ; int high1 = -1
	
	xor ecx, ecx
	rev_loop: ; for (i = 1; i < size; ++i)
		inc ecx
		
		; i & (i - 1) == 0
		push ecx
		mov eax, ecx
		dec eax
		and eax, [esp]
		add esp, 4
		
		; i ^ (1 << high1)
		xor eax, eax
		inc eax
		mov edx, dword [ebp - 24]
		shl eax, dl
		xor eax, ecx
		
		; 1 << (k - high1 - 1)
		mov edx, dword [ebp - 16]
		sub edx, dword [ebp - 24]
		dec edx
		xor eax, eax
		inc eax
		shl eax, dl
		add esp, 4
		
		cmp ecx, [ebp + 12]
		jb rev_loop

	; double *roots = (double*) calloc(2 * size, sizeof(double))
	call calloc_double_2size
	mov [ebp - 4], eax

	; double alpha = 2 * M_PI / size
	fldpi
	push 2
	fimul dword [esp]
	add esp, 4
	fidiv dword [ebp + 12]	

	; for (i = 0; i < size; ++i)
	mov ecx, [ebp + 12]
	mov [ebp - 8], ecx
	roots_loop:
		dec	dword [ebp - 8]

		fld st0
		fimul dword [ebp - 8]
		fsincos

		cmp dword [ebp - 8], 0
		jnz roots_loop

	; double *cur = (double*) calloc(2 * size, sizeof(double));
	call calloc_double_2size
	mov [ebp - 12], eax
	
	; free(rev)
	push dword [ebp - 20]
	call free
	add esp, 4

	; free(roots)
	push dword [ebp - 4]
	call free
	add esp, 4

	; return cur;
	mov eax, [ebp - 12]

	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret

end
