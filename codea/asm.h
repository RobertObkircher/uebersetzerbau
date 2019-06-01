#ifndef __ASM_H__
#define __ASM_H__

enum Register {
    /*caller saved*/
    RDI = 0, /* 1 */
    RSI, /* 2 */
    RDX, /* 3 */
    RCX, /* 4 */
    R8,  /* 5 */
    R9,  /* 6 */
    R10,
    R11,
    RAX, /* last, so it is usually available for the last allocation */
    REG_COUNT,
    R15, // heap pointer
    REGISTER_NONE,
    REGISTER_UNKNOWN,
};

const char* regstr(enum Register reg);

void asm_untag_number(enum Register target);
void asm_untag_list(enum Register target);
void asm_tag_number(enum Register target);
void asm_tag_list(enum Register target);

void asm_move_reg_reg(enum Register source, enum Register target);
void asm_immediate(unsigned long long value, enum Register target);

void asm_xor_immediate(unsigned long long value, enum Register target);
void asm_and_immediate(unsigned long long value, enum Register target);

void asm_add(enum Register source, enum Register target);
void asm_add_immediate(unsigned long long value, enum Register target);

void asm_mul(enum Register source, enum Register target);
void asm_mul_immediate(unsigned long long value, enum Register target);

void asm_or(enum Register source, enum Register target);
void asm_or_immediate(unsigned long long value, enum Register target);

void asm_sub(enum Register source, enum Register target);
void asm_sub_immediate(unsigned long long value, enum Register target);
void asm_neg(enum Register target);

void asm_eq(enum Register source, enum Register target);
void asm_eq_immediate(unsigned long long value, enum Register target);

void asm_ge(enum Register source, enum Register target);
void asm_ge_immediate(unsigned long long value, enum Register target);

void asm_le(enum Register source, enum Register target);
void asm_le_immediate(unsigned long long value, enum Register target);

void asm_return();
void asm_raisesig();

void asm_cons(enum Register source, enum Register target);
void asm_cons_reg_imm(unsigned long long value, enum Register target);
void asm_cons_imm_reg(unsigned long long value, enum Register target);
void asm_cons_imm_imm(unsigned long long v1, unsigned long long v2, enum Register target);

void asm_move_head_reg(enum Register target);
void asm_move_tail_reg(enum Register target);

void asm_jmp_guard(enum Register target, int guard_uid);

#endif
