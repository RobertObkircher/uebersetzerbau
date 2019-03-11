	.file	"asma.c"
	.text
	.globl	asma
	.type	asma, @function
asma: # rdi *a, rsi *b, rdx c
.LFB0:
	.cfi_startproc
        movq    %rdx, %rcx
	andl	$63, %ecx

        movq    (%rdi), %r10
        movq    8(%rdi), %r11

        test $64, %rdx
        cmovz  %r10, %r8
        cmovnz %r11, %r8
        cmovnz %r10, %r11
        cmovnz %r8, %r10

        movq    %r10, %r8
        movq    %r11, %r9

        shld    %cl, %r11, %r10
        shld    %cl, %r8, %r11

        movq     %r10, (%rsi)
        movq     %r11, 8(%rsi)
	ret
	.cfi_endproc
.LFE0:
	.size	asma, .-asma
	.ident	"GCC: (GNU) 8.2.1 20181127"
	.section	.note.GNU-stack,"",@progbits
