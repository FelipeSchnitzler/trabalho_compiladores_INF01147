int main(){
    int a;
    int b;
    a = 1;
    b = a + 1;
    return b;
}

/*
	.file	"foo.c"
	.text
	.globl	main
	.type	main, @function
main:
	# Prologue
	pushq	%rbp
	movq	%rsp, %rbp

	# Body
	movl	$1, -4(%rbp)      # a = 1
	movl	-4(%rbp), %eax    # Carrega a em %eax
	addl	$1, %eax          # %eax = a + 1
	movl	%eax, -8(%rbp)    # b = %eax (b = a + 1)

	# Epilogue
	movl	$0, %eax          # Retorno da função
	popq	%rbp
	ret

	.size	main, .-main
*/


/*
	.file	"foo.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$1, -4(%rbp)
	movl	-4(%rbp), %eax
	addl	$1, %eax
	movl	%eax, -8(%rbp)
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 14.2.1 20240912 (Red Hat 14.2.1-3)"
	.section	.note.GNU-stack,"",@progbits
*/