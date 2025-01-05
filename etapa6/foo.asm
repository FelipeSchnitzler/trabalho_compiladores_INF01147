loadI 2 => r1
storeAI r1 => rfp, 4
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
	movl	$2, %eax
	movl	%eax, -4(%rbp) # 	movl	4(%rbp), %ebx

	# Epilogue
	movl	$0, %eax
	popq	%rbp
	ret
