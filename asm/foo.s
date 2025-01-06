	.file	"foo.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	# Prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# Variáveis locais
	movl	$2, %eax	# loadI 2 => r1
	movl	$3, %ebx	# loadI 3 => r2

	# add r1, r2 => r3
	imull	%ebx, %eax
	movl	%eax, %ecx

	movl	%ecx, -4(%rbp)	# storeAI r3 => rfp, 4
	movl	-4(%rbp), %eax	# loadAI rfp, 4 => r4
	popq	%rbp
	ret

.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 14.2.1 20240912 (Red Hat 14.2.1-3)"
	.section	.note.GNU-stack,"",@progbits
