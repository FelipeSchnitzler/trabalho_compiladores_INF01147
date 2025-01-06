# [NewLanguage] =============================
;main = > int {
;  int a;
;  int b;
;  int c;
;  a = 10;
;  b = 2;
;  c = 0;
;  while (a > 5) {
;    a = a - 1;
;    c = c + 123;
;  };
;  return 0;
;}

; # [ILOC] =============================
	; # loadI 10 => r1
	; # storeAI r1 => rfp, 4
	; # loadI 2 => r2
	; # storeAI r2 => rfp, 8
	; # loadI 0 => r3
	; # storeAI r3 => rfp, 12
	; # L0 : nop
	; # loadAI rfp, 4 => r4
	; # loadI 5 => r5
	; # cmp_GT r4, r5 => r6
	; # cbr r6 => L1, L2
	; # L1 : nop
	; # loadAI rfp, 4 => r7
	; # loadI 1 => r8
	; # sub r7, r8 => r9
	; # storeAI r9 => rfp, 4
	; # loadAI rfp, 12 => r10
	; # loadI 123 => r11
	; # add r10, r11 => r12
	; # storeAI r12 => rfp, 12
	; # jumpI => L0
	; # L2 : nop
	; # RETURN
	; # loadI 0 => r13

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
	movl	$10, %eax	; # loadI 10 => r1
	movl	%eax, -4(%rbp)	; # storeAI r1 => rfp, 4
	movl	$2, %ebx	; # loadI 2 => r2
	movl	%ebx, -8(%rbp)	; # storeAI r2 => rfp, 8
	movl	$0, %ecx	; # loadI 0 => r3
	movl	%ecx, -12(%rbp)	; # storeAI r3 => rfp, 12

L0:
	movl	-4(%rbp), %edx	; # loadAI rfp, 4 => r4
	movl	$5, %esi	; # loadI 5 => r5

	; # cmp_GT r4, r5 => r6
	cmpl	%esi, %edx
	setg	%al
	movzbl	%al, %edi 

	cmpl	$0, %edi
	je	L2
	jmp	L1	; # cbr r6 => L1, L2

L1:
	movl	-4(%rbp), %r8d	; # loadAI rfp, 4 => r7
	movl	$1, %r9d	; # loadI 1 => r8

	; # sub r7, r8 => r9
	subl	%r9d, %r8d
	movl	%r8d, %r10d

	movl	%r10d, -4(%rbp)	; # storeAI r9 => rfp, 4
	movl	-12(%rbp), %r11d	; # loadAI rfp, 12 => r10
	movl	$123, %r12d	; # loadI 123 => r11

	; # add r10, r11 => r12
	addl	%r12d, %r11d
	movl	%r11d, %r13d

	movl	%r13d, -12(%rbp)	; # storeAI r12 => rfp, 12
	jmp	L0	; # jumpI => L0

L2:
	movl	$0, %eax	; # loadI 0 => r13
	popq	%rbp
	ret
