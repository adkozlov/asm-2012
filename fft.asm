; parameters
%define in_data dword [ebp + 8]
%define size dword [ebp + 12]

global fft

; double* fft(const double* in_data, const int size)
fft:
	push ebx ; save regs
	push esi
	push edi
	
	
	
	pop edi ;save regs
	pop esi
	pop ebx
	ret
	
end
