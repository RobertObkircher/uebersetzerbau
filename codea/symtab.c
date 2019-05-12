#include "allocation.h"
#include <stdbool.h>
#include <stdio.h>
#include "symtab.h"
#include "symmap.h"

struct Symtab {
    struct symmap *entries;
};

struct Symtab *symtab_new() {
    struct Symtab *result = malloc_or_exit(sizeof *result);
    result->entries = symmap_new();
    return result;
};

struct Symtab *symtab_new_with_variable(char *name) {
    struct Symtab *result = symtab_new();
    result = symtab_variable_declaration(result, name);
    return result;
}

static struct Symtab *clone(struct Symtab *symtab) {
    struct Symtab *result = malloc_or_exit(sizeof *result);
    result->entries = symmap_new_clone(symtab->entries);
    return result;
}

struct Symtab *symtab_variable_declaration(struct Symtab *symtab, char *name) {
    struct Symtab *result = clone(symtab);
    struct symmap *map = result->entries;
    enum SymType previous = symmap_insert(map, name, SYM_TYPE_VARIABLE);
    if (previous != SYM_TYPE_UNKNOWN) {
        printf("variable name '%s' already used\n", name);
        exit(3);
    }
    return result;
}

struct Symtab *symtab_variable_usage(struct Symtab *symtab, char *name) {
    struct symmap *map = symtab->entries;
    enum SymType type = symmap_lookup(map, name);
    if (type == SYM_TYPE_UNKNOWN) {
        printf("unknown variable '%s'\n", name);
        exit(3);
    }
    if (type != SYM_TYPE_VARIABLE) {
        printf("'%s' is not a variable\n", name);
        exit(3);
    }
    return symtab;
}

struct Symtab *symtab_label_declaration(struct Symtab *symtab, char *name) {
    struct Symtab *result = clone(symtab);
    if (name) {
        struct symmap *map = result->entries;
        enum SymType previous = symmap_insert(map, name, SYM_TYPE_LABEL);
        if (previous != SYM_TYPE_UNKNOWN) {
            printf("label name '%s' already used\n", name);
            exit(3);
        }
    }
    return result;
}

struct Symtab *symtab_label_usage(struct Symtab *symtab, char *name) {
    struct symmap *map = symtab->entries;
    enum SymType type = symmap_lookup(map, name);
    if (type == SYM_TYPE_UNKNOWN) {
        printf("unknown label '%s'\n", name);
        exit(3);
    }
    if (type != SYM_TYPE_LABEL) {
        printf("'%s' is not a label\n", name);
        exit(3);
    }
    return symtab;
}
