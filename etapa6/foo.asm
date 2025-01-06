; # [ILOC] =============================
	; # loadI 3 => r1
	; # storeAI r1 => rfp, 8
	; # loadI 90 => r2
	; # loadAI rfp, 8 => r3
	; # mod r2, r3 => r4
	; # storeAI r4 => rfp, 4

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
	movl	$90, %ebx	; # loadI 90 => r2
	movl	-8(%rbp), %ecx	; # loadAI rfp, 8 => r3

	; # mod r2, r3 => r4
	movl	%ecx, %eax
	cltd
	idivl	%ebx
	movl	%edx, %edx

	movl	%edx, -4(%rbp)	; # storeAI r4 => rfp, 4
	popq	%rbp
	ret
