#ifndef SYMMAP_H
#define SYMMAP_H

enum SymType {
    SYM_TYPE_UNKNOWN,
    SYM_TYPE_VARIABLE,
    SYM_TYPE_LABEL,
};

#define MAP symmap
#define KEY char*
#define VALUE enum SymType
#include "map.h"

#endif
