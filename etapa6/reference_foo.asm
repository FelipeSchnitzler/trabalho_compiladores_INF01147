.LFB0:
	pushq	%rbp
	movq	%rsp, %rbp

	movl	$1, -4(%rbp)
	movl	-4(%rbp), %eax
	
	popq	%rbp
	ret


.LFB0:
	# .cfi_startproc
	pushq	%rbp
	# .cfi_def# .cfa_offset 16
	# .cfi_offset 6, -16
	movq	%rsp, %rbp
	# .cfi_def# .cfa_register 6
	movl	$1, -4(%rbp)
	movl	-4(%rbp), %eax
	popq	%rbp
	# .cfi_def# .cfa 7, 8
	ret
	# .cfi_endproc

; int main(){
; 	int a;
; 	a = 2;
; 	return a;
; }