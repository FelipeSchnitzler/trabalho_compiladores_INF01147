	.file   "program.c"
	.text
	.globl  main
	.type   main, @function
main:
	# Prologue
	pushq   %rbp
	movq    %rsp, %rbp
	movl    $1, %rr1
	movl    %rr1, 4(%rbp)
	movl    4(%rbp), %rr2
	movl    $1, %rr3
	addl    %rr3, %rr2
	movl    %rr2, %rr4
	movl    %rr4, 8(%rbp)
	movl    8(%rbp), %rr5

	# Epilogue
	movl    $0, %eax
	popq    %rbp
	ret