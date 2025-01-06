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
	movl	$3, %eax	; # loadI 3 => r1
	movl	%eax, -8(%rbp)	; # storeAI r1 => rfp, 8
	movl	$4, %ebx	; # loadI 4 => r2
	movl	-8(%rbp), %ecx	; # loadAI rfp, 8 => r3

	; # mod r2, r3 => r4
	cltd
	idivl	%ebx
	movl	%edx, %edx

	movl	%edx, -4(%rbp)	; # storeAI r4 => rfp, 4
	movl	-4(%rbp), %eax	; # loadAI rfp, 4 => r5
	popq	%rbp
	ret
