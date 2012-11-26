; http://pastebin.com/uGr4VT3b
section .text

global fft

; double* fft(const double* in_data, const int size)
fft:
	push ebp
	mov ebp, esp
	sub esp, 20 ; todo: local vars
	push ebx
	push esi
	push edi
	
	; double *roots = (double*) calloc(2 * size, sizeof(double))
	push 8 ; sizeof(double)
	push dword [ebp + 12]
	shl [esp], 1
	call calloc
	add esp, 8
	mov [ebp - 8], eax
	
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
		
		fimul dword ecx
		fld st0
		fsincos
		
		test ecx, ecx
		jnz roots_loop
		
	
	
	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret	
end
