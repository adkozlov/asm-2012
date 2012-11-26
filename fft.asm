section .const

pi dq 3.14159265

section .text

; parameters
%define in_data dword [ebp + 8]
%define size dword [ebp + 12]

global fft

; double* fft(const double* in_data, const int size)
fft:
	push ebx ; save regs
	push esi
	push edi
	
	; double *roots = (double*) calloc(2 * size, sizeof(double))
	roots dq 2 * size dup (0)
	
	; double alpha = 2 * M_PI / size
	movsd xmm0, pi
	mulsd xmm0, 2
	divsd xmm0, size
	
	; for (i = 0; i < size; ++i)
	xor ecx, ecx 
	roots_1:
		cmp ecx, size
		jae roots_2
			
		movsd xmm1, ecx
		
		inc ecx
		jmp roots_1
	
	roots_2:	
	
	
	pop edi ;save regs
	pop esi
	pop ebx
	ret
	
end
