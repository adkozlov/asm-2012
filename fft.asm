extern _calloc
extern _free

section .text

new_int_size:
	push 4 ; sizeof(int)
	push dword [ebp + 12]
	call _calloc
	add esp, 8

new_double_2size:
	push 8 ; sizeof(double)
	push dword [ebp + 12]
	shl [esp], 1
	call _calloc
	add esp, 8
	

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
	jmp new_double_2size
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
		mov [ebp + ]
		
		cmp dword [ebp - 8], 0
		jnz roots_loop
		
	
	
	pop edi
	pop esi
	pop ebx
	mov esp, ebp
	pop ebp
	ret	
end
