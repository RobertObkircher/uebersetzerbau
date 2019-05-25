#include "allocation.h"
#include "panic.h"
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

struct Symtab *symtab_new_clone(struct Symtab *symtab) {
    struct Symtab *result = clone(symtab);
    return result;
}

struct Symtab *symtab_variable_declaration(struct Symtab *symtab, char *name) {
    struct Symtab *result = clone(symtab);
    struct symmap *map = result->entries;
    enum SymType previous = symmap_insert(map, name, SYM_TYPE_VARIABLE);
    if (previous != SYM_TYPE_UNKNOWN) {
        panic3("variable name '%s' already used", name);
    }
    return result;
}

struct Symtab *symtab_variable_usage(struct Symtab *symtab, char *name) {
    struct symmap *map = symtab->entries;
    enum SymType type = symmap_lookup(map, name);
    if (type == SYM_TYPE_UNKNOWN) {
        panic3("unknown variable '%s'", name);
    }
    if (type != SYM_TYPE_VARIABLE) {
        panic3("'%s' is not a variable", name);
    }
    return symtab;
}

struct Symtab *symtab_label_declaration(struct Symtab *symtab, char *name) {
    struct Symtab *result = clone(symtab);
    if (name) {
        struct symmap *map = result->entries;
        enum SymType previous = symmap_insert(map, name, SYM_TYPE_LABEL);
        if (previous != SYM_TYPE_UNKNOWN) {
            panic3("label name '%s' already used", name);
        }
    }
    return result;
}

struct Symtab *symtab_label_usage(struct Symtab *symtab, char *name) {
    struct symmap *map = symtab->entries;
    enum SymType type = symmap_lookup(map, name);
    if (type == SYM_TYPE_UNKNOWN) {
        panic3("unknown label '%s'", name);
    }
    if (type != SYM_TYPE_LABEL) {
        panic3("'%s' is not a label", name);
    }
    return symtab;
}

int symtab_size(struct Symtab *symtab) {
    return symmap_size(symtab->entries);
}

// TODO this is ugly
static void(*foreach_fn)(char* key);
static void foreach_var(char *key, enum SymType type) {
    if (type == SYM_TYPE_VARIABLE) {
        foreach_fn(key);
    }
}

void symtab_foreach_variable(struct Symtab *symtab, void(*iter)(char *key)) {
    foreach_fn = iter;
    symmap_foreach(symtab->entries, foreach_var);
}
