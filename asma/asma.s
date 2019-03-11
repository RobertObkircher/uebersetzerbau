	.file	"asma.c"
	.text
	.globl	asma
	.type	asma, @function
asma: # rdi *a, rsi *b, rdx c
.LFB0:
	.cfi_startproc
        movq    %rdx, %rcx
	andl	$63, %ecx

        # r8, r10 = a[0]
        movq    (%rdi), %r10
        movq    %r10, %r8

        # r9, r11 = a[1]
        movq    8(%rdi), %r11
        movq    %r11, %r9

        test $64, %rdx
        jz ShiftLeft
ShiftRight:
        neg     %rdx
        shrd    %cl, %r11, %r10
        shrd    %cl, %r8, %r11
        jmp Exit
ShiftLeft:
        shld    %cl, %r11, %r10
        shld    %cl, %r8, %r11
Exit:
        movq    %r10, (%rsi)
        movq    %r11, 8(%rsi)
	ret
	.cfi_endproc
.LFE0:
	.size	asma, .-asma
	.ident	"GCC: (GNU) 8.2.1 20181127"
	.section	.note.GNU-stack,"",@progbits
