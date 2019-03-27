	.file	"asmb.c"
	.text
	.globl	asmb
	.type	asmb, @function
asmb: # rdi *a, rsi *b, rdx c, rcx n
.LFB0:
	.cfi_startproc

        # 1111 2222 3333 (if long was 4 bits)
        # 1112 2223 3331 (0 longs, 1 bits)
        # 2223 3331 1112 (1 longs, 1 bits)
        # 3331 1112 2223 (2 longs, 1 bits)

        # result[n] = source[n+longs %] <<<< source[n+longs+1 %]

        # rax    loop counter n-1..0
        # rcx    number of bits to shift within a long
        # rdx    number_of_longs
        # rsi   *b
        # rdi   *a
        # r8     relative_read_position
        # r9     n-1 (n is a power of two, so this simplifies modulo n)
        # r10    shifted_into_r11
        # r11    result

        #pushq %r12

        # compute n-1 in %rax
        movq %rcx, %rax
        jz exit # n = 0
        dec %rax

        # store n-1 to compute modulo n
        movq %rax, %r9

        # bits
        movq %rdx, %rcx
        and $63, %rcx

        # compute number_of_longs
        shr $6, %rdx
        
        # compute initial relative_read_position
        # (n+longs+1)&(n-1)
        movq %rdx, %r8
        inc %r8
        and %r9, %r8 # %n

loop:
        # read first value from relative_read_position
        movq (%rdi, %r8), %r10
        dec %r8
        and %r9, %r8 # %n

        # read the second value from relative_read_position
        movq (%rdi, %r8), %r11

        shld %cl, %r10, %r11
        movq %r11, (%rsi, %rax)

        add $-1, %rax
        jnz loop
exit:

        #popq %r12
	ret
	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (GNU) 8.2.1 20181127"
	.section	.note.GNU-stack,"",@progbits
