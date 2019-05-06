#include "allocation.h"
#include <stdbool.h>
#include <stdio.h>
#include "symtab.h"
#include "symmap.h"

struct Symtab {
    int scope;
    int capacity;
    struct symmap **sets;
};

struct Symtab* symtab_new() {
    struct Symtab *result = calloc_or_exit(1, sizeof *result);
    return result;
};

void symtab_enter_scope(struct Symtab *symtab) {
    ++symtab->scope;
    if (symtab->scope >= symtab->capacity) {
        symtab->capacity *= 2;
        if (symtab->capacity == 0)
            symtab->capacity = 16;
        symtab->sets = reallocarray_or_exit( symtab->sets,
                symtab->capacity,
                sizeof *symtab->sets);
    }
    symtab->sets[symtab->scope] = symmap_new();
}

void symtab_leave_scope(struct Symtab *symtab) {
    free(symtab->sets[symtab->scope]);
    --symtab->scope;
}

static struct symmap *current_map(struct Symtab *symtab) {
    struct symmap *map = symtab->sets[symtab->scope];
    return map;
}

void symtab_variable_declaration(struct Symtab *symtab, char *name) {
    struct symmap *map = current_map(symtab);
    enum SymType previous = symmap_insert(map, name, SYM_TYPE_VARIABLE);
    if (previous != SYM_TYPE_UNKNOWN && previous != SYM_TYPE_VARIABLE) {
        printf("variable can not be defined\n");
        exit(3);
    }
}

void symtab_variable_usage(struct Symtab *symtab, char *name) {
    struct symmap *map = current_map(symtab);
    enum SymType type = symmap_lookup(map, name);
    if (type == SYM_TYPE_UNKNOWN) {
        printf("variable unknown\n");
        exit(3);
    }
    if (type != SYM_TYPE_VARIABLE) {
        printf("not a variable\n");
        exit(3);
    }
}

void symtab_label_declaration(struct Symtab *symtab, char *name) {
    struct symmap *map = current_map(symtab);
    enum SymType previous = symmap_insert(map, name, SYM_TYPE_LABEL);
    if (previous != SYM_TYPE_UNKNOWN && previous != SYM_TYPE_LABEL) {
        printf("label can not be defined\n");
        exit(3);
    }
}

void symtab_label_usage(struct Symtab *symtab, char *name) {
    struct symmap *map = current_map(symtab);
    enum SymType type = symmap_lookup(map, name);
    if (type == SYM_TYPE_UNKNOWN) {
        printf("label unknown\n");
        exit(3);
    }
    if (type != SYM_TYPE_LABEL) {
        printf("not a symbol\n");
        exit(3);
    }
}
