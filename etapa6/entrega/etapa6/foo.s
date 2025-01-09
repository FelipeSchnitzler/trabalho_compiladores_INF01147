; # [ILOC] =============================
	; # loadI 3 => r1
	; # storeAI r1 => rfp, 8
	; # loadI 4 => r2
	; # loadAI rfp, 8 => r3
	; # mod r2, r3 => r4
	; # storeAI r4 => rfp, 4
	; # RETURN
	; # loadAI rfp, 4 => r5

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
	movl	$3, %r8d	; # loadI 3 => r1
	movl	%r8d, -8(%rbp)	; # storeAI r1 => rfp, 8
	movl	$4, %r9d	; # loadI 4 => r2
	movl	-8(%rbp), %r10d	; # loadAI rfp, 8 => r3

	; # mod r2, r3 => r4
	cltd
	idivl	%r9d
	movl	%edx, %r11d

	movl	%r11d, -4(%rbp)	; # storeAI r4 => rfp, 4
	movl	-4(%rbp), %r8d	; # loadAI rfp, 4 => r5
	popq	%rbp
	ret
