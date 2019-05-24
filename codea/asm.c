#include "asm.h"
#include "regmap.h"
#include <stdio.h>
#include <stdlib.h>

const char* regstr(enum Register reg) {
    switch(reg) {
        case RDI: return "rdi";
        case RSI: return "rsi";
        case RDX: return "rdx";
        case RCX: return "rcx";
        case R8: return "r8";
        case R9: return "r9";
        case RAX: return "rax";
        case R10: return "r10";
        case R11: return "r11";
        default:
            printf("unknown register %d\n", reg);
            exit(41);
    }
}

void asm_untag_number(enum Register target) {
    const char *to = regstr(target);

    printf("\tbt $0, %%%s\n", to);
    printf("\tjc raisesig\n");
    printf("\tsar $1, %%%s\n", to);
}

void asm_untag_list(enum Register target) {
    const char *to = regstr(target);

    printf("\tbt $0, %%%s\n", to);
    printf("\tjnc raisesig\n");
    printf("\tdec %%%s\n", to);
}

void asm_tag_number(enum Register target) {
    const char *to = regstr(target);
    printf("\tshl $1, %%%s\n", to);
}

void asm_tag_list(enum Register target) {
    const char *to = regstr(target);
    printf("\tinc %%%s\n", to);
}

void asm_move_reg_reg(enum Register source, enum Register target) {
    if (source != target) {
        const char *from = regstr(source);
        const char *to = regstr(target);
        printf("\tmovq %%%s, %%%s\n", from, to);
    }
}

void asm_xor1(enum Register target) {
    const char *to = regstr(target);
    printf("\txor $1, %%%s\n", to);
}

void asm_add(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    printf("\tadd %%%s, %%%s\n", from, to);
}

void asm_add_immediate(unsigned long long value, enum Register target) {
    const char *to = regstr(target);
    printf("\tadd %d, %%%s\n", value, to);
}

void asm_immediate(unsigned long long value, enum Register target) {
    const char *to = regstr(target);
    printf("\tmovq $%d, %%%s\n", value, to);
}

void asm_return() {
    printf("\tret\n");
}

void asm_raisesig() {
    printf("\tjmp raisesig\n");
}
