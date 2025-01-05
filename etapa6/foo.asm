loadI 2 => r1
storeAI r1 => rfp, 4
RETURN
loadAI rfp, 4 => r2

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
	movl	$2, %eax
	movl	%eax, -4(%rbp)	# storeAI r1 => rfp, 4

	movl	-4(%rbp), %eax	# loadAI rfp, 4 => r2

	popq	%rbp
	ret
