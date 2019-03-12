	.file	"asmb.c"
	.text
	.globl	asmb
	.type	asmb, @function
asmb:
.LFB0:
	.cfi_startproc
	movq	%rcx, %r9
	movq	%rdx, %rax
	shrq	$6, %rax
	andl	$63, %edx
	je	.L2
	movq	%rdx, %r10
	testq	%rcx, %rcx
	je	.L12
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	movq	%rax, %r8
	negq	%r8
	movq	%rcx, %rbp
	subq	%rax, %rbp
	leaq	(%rsi,%rax,8), %rbx
	movl	%edx, %r11d
	negl	%r11d
.L6:
	leaq	-1(%r8), %rax
	movl	$0, %edx
	divq	%r9
	movq	(%rdi,%rdx,8), %rsi
	movl	%r11d, %ecx
	shrq	%cl, %rsi
	movq	%r8, %rax
	movl	$0, %edx
	divq	%r9
	movq	(%rdi,%rdx,8), %rax
	movl	%r10d, %ecx
	salq	%cl, %rax
	orq	%rax, %rsi
	movq	%rsi, (%rbx,%r8,8)
	addq	$1, %r8
	cmpq	%rbp, %r8
	jne	.L6
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
.L12:
	.cfi_restore 3
	.cfi_restore 6
	ret
.L2:
	testq	%rcx, %rcx
	je	.L10
	movq	%rax, %rcx
	negq	%rcx
	movq	%r9, %r8
	subq	%rax, %r8
	leaq	(%rsi,%rax,8), %rsi
.L5:
	movq	%rcx, %rax
	movl	$0, %edx
	divq	%r9
	movq	(%rdi,%rdx,8), %rax
	movq	%rax, (%rsi,%rcx,8)
	addq	$1, %rcx
	cmpq	%rcx, %r8
	jne	.L5
	ret
.L10:
	ret
	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (GNU) 8.2.1 20181127"
	.section	.note.GNU-stack,"",@progbits
