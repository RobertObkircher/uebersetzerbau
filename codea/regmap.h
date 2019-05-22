#ifndef REGMAP_H
#define REGMAP_H

#include "asm.h"

struct RegInfo {
    enum Register reg;
};

#define MAP regmap
#define KEY char*
#define VALUE struct RegInfo
#include "map.h"

#endif
