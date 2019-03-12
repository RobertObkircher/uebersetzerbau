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

        # rax    n-1 (n is a power of two, so this simplifies modulo n)
        # rcx    n; also serves as loop counter
        # rdx    c
        # rsi   *b
        # rdi   *a
        # r8     relative_read_position
        # r9     relative_write_position
        # r10    first_read_value
        # r11    to_write

        # r12    number_of_longs

        pushq %r12

        movq %rcx, %rax
        dec %rax
        jz .EXIT
.LOOP:
        #TODO 
        loop .LOOP
.EXIT:

        popq %r12
	ret
	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (GNU) 8.2.1 20181127"
	.section	.note.GNU-stack,"",@progbits
