# [ILOC] =============================
	# loadI 2 => r1
	# loadI 1 => r2
	# cmp_GT r1, r2 => r3
	# storeAI r3 => rfp, 4
	# RETURN
	# loadAI rfp, 4 => r4



; int main(){
	; int a;
	; a = 2 < 1 ;
	; return a;
; }

=================================================
	.file	"program.c"
	.text
	.globl	main
	.type	main, @function
main:
	# Prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# Variáveis locais
	movl	$2, %eax	# loadI 2 => r1
	movl	$1, %ebx	# loadI 1 => r2
	# cmp_GT r1, r2 => r3
	cmpl	%eax, %ebx
	setg	%al
	movzbl	%al, %ecx 

	movl	%ecx, -4(%rbp)	# storeAI r3 => rfp, 4
	movl	-4(%rbp), %eax	# loadAI rfp, 4 => r4
	popq	%rbp
	ret
