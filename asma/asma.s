	.file	"asma.c"
	.text
	.globl	asma
	.type	asma, @function
asma:
.LFB0:
	.cfi_startproc
	movq	%rdx, %rax
	shrq	$6, %rax
	movq	%rax, %rcx
	andl	$1, %ecx
	leaq	(%rdi,%rcx,8), %r11
	andl	$63, %edx
	movq	(%r11), %r9
	movl	%edx, %ecx
	salq	%cl, %r9
	movq	%rax, %rcx
	andl	$1, %ecx
	xorq	$1, %rcx
	movl	%edx, %r10d
	negl	%r10d
	movq	(%rdi,%rcx,8), %r8
	movl	%r10d, %ecx
	shrq	%cl, %r8
	orq	%r9, %r8
	movq	%r8, (%rsi)
	notq	%rax
	andl	$1, %eax
	movq	(%rdi,%rax,8), %rax
	movl	%edx, %ecx
	salq	%cl, %rax
	movq	(%r11), %rdx
	movl	%r10d, %ecx
	shrq	%cl, %rdx
	orq	%rdx, %rax
	movq	%rax, 8(%rsi)
	ret
	.cfi_endproc
.LFE0:
	.size	asma, .-asma
	.ident	"GCC: (GNU) 8.2.1 20181127"
	.section	.note.GNU-stack,"",@progbits
