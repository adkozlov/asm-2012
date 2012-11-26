extern _calloc
extern _free

section .text

calloc_int_size:
	push 4 ; sizeof(int)
	push dword [ebp + 12] ; size
	call _calloc
	add esp, 8
	ret

calloc_double_2size:
	push 8 ; sizeof(double)
	push dword [ebp + 12] ; size
	shl dword [esp], 1
	call _calloc
	add esp, 8
	ret
	
free:
	mov eax, ebp
	sub eax, [esp + 4]
	push eax
	call _free
	add esp, 4
	ret
	

global fft

; double* fft(const double *in_data, const int size)
fft:
	push ebp
	mov ebp, esp
	sub esp, 20 ; todo: local vars
	push ebx
	push esi
	push edi
	
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
	
	; free(roots)
	push 4
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
