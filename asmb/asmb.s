	.file	"asmb.c"
	.text
	.globl	asmb
	.type	asmb, @function
asmb: # rdi *a, rsi *b, rdx c, rcx n
.LFB0:
	.cfi_startproc
        # rax    loop counter n-1..0
        # rcx    number of bits to shift within a long
        # rdx    number_of_longs
        # rsi    *b
        # rdi    *a
        # r8     relative_read_position ((loop_counter-longs)%n)
        # r9     n-1 (n is a power of two, so this simplifies modulo n)
        # r10    shifted_into_r11
        # r11    result

        # compute n-1 in %rax
        movq %rcx, %rax
        add $-1, %rax
        js exit # n = 0

        # store n-1, so we can compute %n with &(n-1)
        movq %rax, %r9

        # bits
        movq %rdx, %rcx
        and $63, %rcx

        # number_of_longs
        shr $6, %rdx
        
        # relative_read_position
        movq %rax, %r8
        sub %rdx, %r8
        and %r9, %r8

loop:
        # a[(i-longs)%n]
        movq (%rdi, %r8, 8), %r11

        # a[(i-longs-1)%n]
        dec %r8
        and %r9, %r8 # %n
        movq (%rdi, %r8, 8), %r10

        # b[i] = a[(i-longs)%n] `shld` a[(i-longs-1)%n]
        shld %cl, %r10, %r11
        movq %r11, (%rsi, %rax, 8)

        add $-1, %rax
        jns loop
exit:
	ret
	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (GNU) 8.2.1 20181127"
	.section	.note.GNU-stack,"",@progbits
