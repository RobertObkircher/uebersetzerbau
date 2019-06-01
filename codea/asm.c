#include "asm.h"
#include "panic.h"
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
        case R15: return "r15";
        default: panic("unknown register %d", reg);
    }
}

const char* regstr8(enum Register reg) {
    switch(reg) {
        case RDI: return "dil";
        case RSI: return "sil";
        case RDX: return "dl";
        case RCX: return "cl";
        case R8: return "r8b";
        case R9: return "r9b";
        case RAX: return "al";
        case R10: return "r10b";
        case R11: return "r11b";
        case R15: return "r15b";
        default: panic("unknown register %d", reg);
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

void asm_xor_immediate(unsigned long long value, enum Register target) {
    if (value) {
        const char *to = regstr(target);
        printf("\txor $%d, %%%s\n", value, to);
    }
}

void asm_and_immediate(unsigned long long value, enum Register target) {
    if (value != -1) {
        const char *to = regstr(target);
        printf("\tand $%d, %%%s\n", value, to);
    }
}

void asm_add(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    printf("\tadd %%%s, %%%s\n", from, to);
}

void asm_add_immediate(unsigned long long value, enum Register target) {
    if (value) {
        const char *to = regstr(target);
        printf("\tadd $%d, %%%s\n", value, to);
    }
}

void asm_mul(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    printf("\timul %%%s, %%%s\n", from, to);
}

void asm_mul_immediate(unsigned long long value, enum Register target) {
    if (value != 1) {
        const char *to = regstr(target);
        printf("\timul $%d, %%%s\n", value, to);
    }
}

void asm_or(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    printf("\tor %%%s, %%%s\n", from, to);
}

void asm_or_immediate(unsigned long long value, enum Register target) {
    if (value) {
        const char *to = regstr(target);
        printf("\tor $%d, %%%s\n", value, to);
    }
}

void asm_sub(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    printf("\tsub %%%s, %%%s\n", from, to);
}

void asm_sub_immediate(unsigned long long value, enum Register target) {
    if (value) {
        const char *to = regstr(target);
        printf("\tsub $%d, %%%s\n", value, to);
    }
}

void asm_neg(enum Register target) {
    const char *to = regstr(target);
    printf("\tneg %%%s\n", to);
}

void asm_eq(enum Register source, enum Register target) {
    if (source != target) {
        const char *from = regstr(source);
        const char *to = regstr(target);
        printf("\tcmp %%%s, %%%s\n", from, to);
        printf("\tsete %%%s\n", regstr8(target));
        asm_and_immediate(1, target);
    } else {
        asm_immediate(1, target);
    }
}

void asm_eq_immediate(unsigned long long value, enum Register target) {
    const char *to = regstr(target);
    printf("\tcmp $%d, %%%s\n", value, to);
    printf("\tsete %%%s\n", regstr8(target));
    asm_and_immediate(1, target);
}

void asm_ge(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    printf("\tcmp %%%s, %%%s\n", from, to);
    printf("\tsetge %%%s\n", regstr8(target));
    asm_and_immediate(1, target);
}

void asm_ge_immediate(unsigned long long value, enum Register target) {
    const char *to = regstr(target);
    printf("\tcmp $%d, %%%s\n", value, to);
    printf("\tsetge %%%s\n", regstr8(target));
    asm_and_immediate(1, target);
}

void asm_le(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    printf("\tcmp %%%s, %%%s\n", from, to);
    printf("\tsetle %%%s\n", regstr8(target));
    asm_and_immediate(1, target);
}

void asm_le_immediate(unsigned long long value, enum Register target) {
    const char *to = regstr(target);
    printf("\tcmp $%d, %%%s\n", value, to);
    printf("\tsetle %%%s\n", regstr8(target));
    asm_and_immediate(1, target);
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

void asm_cons(enum Register source, enum Register target) {
    const char *from = regstr(source);
    const char *to = regstr(target);
    const char *heap = regstr(R15);

    printf("\tmovq %%%s, (%%%s)\n", from, heap);
    printf("\tmovq %%%s, 8(%%%s)\n", to, heap);
    asm_move_reg_reg(R15, target);
    asm_add_immediate(16, R15);
}

void asm_cons_reg_imm(unsigned long long value, enum Register target) {
    const char *to = regstr(target);
    const char *heap = regstr(R15);

    printf("\tmovq %%%s, (%%%s)\n", to, heap);
    printf("\tmovq $%d, 8(%%%s)\n", value, heap);
    asm_move_reg_reg(R15, target);
    asm_add_immediate(16, R15);
}

void asm_cons_imm_reg(unsigned long long value, enum Register target) {
    const char *to = regstr(target);
    const char *heap = regstr(R15);

    printf("\tmovq $%d, (%%%s)\n", value, heap);
    printf("\tmovq %%%s, 8(%%%s)\n", to, heap);
    asm_move_reg_reg(R15, target);
    asm_add_immediate(16, R15);
}

void asm_cons_imm_imm(unsigned long long v1, unsigned long long v2, enum Register target) {
    const char *to = regstr(target);
    const char *heap = regstr(R15);

    printf("\tmovq $%d, (%%%s)\n", v1, heap);
    printf("\tmovq $%d, 8(%%%s)\n", v2, heap);
    asm_move_reg_reg(R15, target);
    asm_add_immediate(16, R15);
}

void asm_move_head_reg(enum Register target) {
    const char *to = regstr(target);
    printf("\tmovq (%%%s), %%%s\n", to, to);
}

void asm_move_tail_reg(enum Register target) {
    const char *to = regstr(target);
    printf("\tmovq 8(%%%s), %%%s\n", to, to);
}

void asm_jmp_guard(enum Register target, int guard_uid) {
    const char *to = regstr(target);
    printf("\tcmp $0 %%%s\n", to);
    printf("\tje .G%d\n", guard_uid);
}

