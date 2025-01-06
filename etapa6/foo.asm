; # [ILOC] =============================
	; # loadI 3 => r1
	; # storeAI r1 => rfp, 8
	; # loadI 30 => r2
	; # loadAI rfp, 8 => r3
	; # mod r2, r3 => r4
	; # storeAI r4 => rfp, 4

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
	movl	$3, %r8d	; # loadI 3 => r1
	movl	%r8d, -8(%rbp)	; # storeAI r1 => rfp, 8
	movl	$30, %r9d	; # loadI 30 => r2
	movl	-8(%rbp), %r10d	; # loadAI rfp, 8 => r3

	; # mod r2, r3 => r4
Unknown binary operation

	movl	%r11d, -4(%rbp)	; # storeAI r4 => rfp, 4
	popq	%rbp
	ret
