; # [ILOC] =============================
	; # loadI 109 => r1
	; # storeAI r1 => rfp, 8
	; # loadI 0 => r2
	; # storeAI r2 => rfp, 12
	; # loadAI rfp, 8 => r3
	; # loadAI rfp, 12 => r4
	; # and r3, r4 => r5
	; # storeAI r5 => rfp, 4
	; # loadAI rfp, 4 => r6
	; # loadI 5 => r7
	; # add r6, r7 => r8
	; # storeAI r8 => rfp, 16
	; # RETURN
	; # loadI 0 => r9

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
	movl	$109, %eax	; # loadI 109 => r1
	movl	%eax, -8(%rbp)	; # storeAI r1 => rfp, 8
	movl	$0, %ebx	; # loadI 0 => r2
	movl	%ebx, -12(%rbp)	; # storeAI r2 => rfp, 12
	movl	-8(%rbp), %ecx	; # loadAI rfp, 8 => r3
	movl	-12(%rbp), %edx	; # loadAI rfp, 12 => r4

	; # and r3, r4 => r5
	andl	%ecx, %edx
	movl	%edx, %esi
	movl	%esi, -4(%rbp)	; # storeAI r5 => rfp, 4
	movl	-4(%rbp), %edi	; # loadAI rfp, 4 => r6
	movl	$5, %r8d	; # loadI 5 => r7

	; # add r6, r7 => r8
	addl	%r8d, %edi
	movl	%edi, %r9d

	movl	%r9d, -16(%rbp)	; # storeAI r8 => rfp, 16
	movl	$0, %eax	; # loadI 0 => r9
	popq	%rbp
	ret
