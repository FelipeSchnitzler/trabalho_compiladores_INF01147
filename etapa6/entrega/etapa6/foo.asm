; # [ILOC] =============================
	; # loadI 3 => r1
	; # storeAI r1 => rfp, 8
	; # RETURN
	; # loadAI rfp, 8 => r2

=================================================
	.file	"program.c"
	.text
	.globl	main
	.type	main, @function
main:
	# Prologo
	pushq	%rbp
	movq	%rsp, %rbp

	;#Main 
	movl	$3, %eax	; # loadI 3 => r1
	movl	%eax, -8(%rbp)	; # storeAI r1 => rfp, 8
	movl	-8(%rbp), %eax	; # loadAI rfp, 8 => r2
	popq	%rbp
	ret
