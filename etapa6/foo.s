; # [ILOC] =============================
	; # loadI 1 => r1
	; # storeAI r1 => rfp, 4
	; # loadI 3 => r2
	; # storeAI r2 => rfp, 8
	; # RETURN
	; # loadAI rfp, 8 => r3

 ;# =================================================
	.file	"program.c"
	.text
	.globl	main
	.type	main, @function
main:
	# Prologo
	pushq	%rbp
	movq	%rsp, %rbp

	;#Main 
	movl	$1, %r8d	; # loadI 1 => r1
	movl	%r8d, -4(%rbp)	; # storeAI r1 => rfp, 4
	movl	$3, %r9d	; # loadI 3 => r2
	movl	%r9d, -8(%rbp)	; # storeAI r2 => rfp, 8
	movl	-8(%rbp), %eax	; # loadAI rfp, 8 => r3
	popq	%rbp
	ret
