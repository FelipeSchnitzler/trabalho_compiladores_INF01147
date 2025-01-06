.LFB0:
	pushq	%rbp
	movq	%rsp, %rbp

	movl	$1, -4(%rbp)
	movl	-4(%rbp), %eax
	
	popq	%rbp
	ret


.LFB0:
	# .cfi_startproc
	pushq	%rbp
	# .cfi_def# .cfa_offset 16
	# .cfi_offset 6, -16
	movq	%rsp, %rbp
	# .cfi_def# .cfa_register 6
	movl	$1, -4(%rbp)
	movl	-4(%rbp), %eax
	popq	%rbp
	# .cfi_def# .cfa 7, 8
	ret
	# .cfi_endproc

; int main(){
; 	int a;
; 	a = 2;
; 	return a;
; }


movl    $2, %eax        # Coloca 2 em r1 (%eax)
movl    $1, %ebx        # Coloca 1 em r2 (%ebx)

cmpl    %ebx, %eax      # Compara r1 (%eax) > r2 (%ebx)
setg    %al             # Define %al como 1 se r1 > r2; caso contrário, 0
movzbl  %al, %ecx       # Expande %al (8 bits) para %ecx (32 bits)

movl    %ecx, -4(%rbp)  # Armazena o resultado na variável local
movl    -4(%rbp), %eax  # Move o resultado para o registrador de retorno
