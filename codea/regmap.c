#include <string.h>
#include "regmap.h"

#define MAP regmap
#define KEY char*
#define VALUE struct Reg
#define NIL (struct Reg) {}
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
