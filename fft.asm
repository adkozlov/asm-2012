; http://pastebin.com/uGr4VT3b
section .text

; parameters
%define in_data dword [ebp + 8]
%define size dword [ebp + 12]

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
	fmul 2
	fdiv size	
	
	; for (i = 0; i < size; ++i)
	mov ecx, size 
	roots_loop:		
		movsd xmm1, ecx
		mulsd xmm1, xmm0
		
		inc ecx
		jnz roots_loop
		
	
	
	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret	
end
