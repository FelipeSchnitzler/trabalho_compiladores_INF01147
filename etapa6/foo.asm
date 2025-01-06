# [ILOC] =============================
	# loadI 2 => r1
	# loadI 3 => r2
	# add r1, r2 => r3
	# storeAI r3 => rfp, 4
	# RETURN
	# loadAI rfp, 4 => r4

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
	movl	$3, %ebx	# loadI 3 => r2

	# add r1, r2 => r3
	addl	%ebx, %eax
	movl	%eax, %ecx

	movl	%ecx, -4(%rbp)	# storeAI r3 => rfp, 4
	movl	-4(%rbp), %eax	# loadAI rfp, 4 => r4
	popq	%rbp
	ret
