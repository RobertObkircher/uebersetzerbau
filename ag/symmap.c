#include <string.h>
#include "symmap.h"

#define MAP symmap
#define KEY char*
#define VALUE enum SymType
#define NIL SYM_TYPE_UNKNOWN
#define MAP_IMPLEMENTATION
#include "map.h"

static unsigned int hash(KEY key) {
    unsigned int hash = 0;
    for (unsigned int i = 0; key[i] != 0; ++i) {
        unsigned int c = key[i];
        unsigned int mask = sizeof(unsigned int) - 1;
        hash ^= c << (i & mask);
    }
    return hash;
}

static int cmp(KEY key_1, KEY key_2) {
    return strcmp(key_1, key_2);
}
