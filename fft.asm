; http://pastebin.com/uGr4VT3b
section .text

; parameters
in_data dword [ebp + 8]
size dword [ebp + 12]

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
	add esp, 8 ; pointer in eax
	
	; double alpha = 2 * M_PI / size
	fldpi
	push 2
	fimul dword [esp]
	add esp, 4
	fidiv dword [ebp + 12]
	
	fld st0
	fsincos
	
	; for (i = 0; i < size; ++i)
	mov ecx, size 
	roots_loop:		
		
		
		inc ecx
		jnz roots_loop
		
	
	
	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret	
end
