#ifndef REGMAP_H
#define REGMAP_H

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

struct Reg {
    enum Register reg;
};

#define MAP regmap
#define KEY char*
#define VALUE struct Reg
#include "map.h"

#endif
