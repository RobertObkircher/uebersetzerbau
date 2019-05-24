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
    RAX,
    R10,
    R11,
    REG_COUNT,
};

const char* regstr(enum Register reg);

void asm_untag_number(enum Register target);
void asm_untag_list(enum Register target);
void asm_tag_number(enum Register target);
void asm_tag_list(enum Register target);

void asm_move_reg_reg(enum Register source, enum Register target);
void asm_immediate(unsigned long long value, enum Register target);

void asm_xor1(enum Register target);

void asm_add(enum Register source, enum Register target);
void asm_add_immediate(unsigned long long value, enum Register target);

void asm_return();
void asm_raisesig();

#endif
