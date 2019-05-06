/*
 * Usage:
 * 
 * name.h
 *     #define MAP name
 *     #define KEY char*
 *     #define VALUE int
 *     #include "map.h"
 *
 * name.c
 *     #define MAP name
 *     #define KEY char*
 *     #define VALUE int
 *     #define NIL 0
 *     #define MAP_IMPLEMENTATION
 *     #include "map.h"
 *     static unsigned int hash(KEY key) {...}
 *     static int cmp(KEY key_1, KEY key_2) {...}
 */

#if !defined(MAP)
#error map name not specified.
#endif

#if !defined(KEY)
#error map KEY type not specified.
#endif

#if !defined(VALUE)
#error map VALUE type not specified.
#endif

// https://stackoverflow.com/a/1489985
#define PASTER(prefix, name) prefix##_##name
#define EVALUATOR(prefix, name) PASTER(prefix, name)
#define FN(name) EVALUATOR(MAP, name)

#ifndef MAP_IMPLEMENTATION
struct MAP;
struct MAP *FN(new)();
void FN(delete)();
VALUE FN(insert)(struct MAP *map, KEY key, VALUE value);
VALUE FN(lookup)(struct MAP *map, KEY key);
VALUE FN(remove)(struct MAP *map, KEY key);
int FN(size)(struct MAP *map);
#endif

#ifdef MAP_IMPLEMENTATION
#include "allocation.h"
#include <stdlib.h>

static unsigned int hash(KEY key);
static int cmp(KEY key_1, KEY key_2);

struct Entry {
    KEY key;
    VALUE value;
    struct Entry *next;
};

struct MAP {
    int capacity;
    int size;
    struct Entry **entries;
};

struct MAP *FN(new)() {
    struct MAP *map = malloc_or_exit(sizeof *map);
    map->capacity = 8;
    map->size = 0;
    map->entries = malloc_or_exit(map->capacity * sizeof *map->entries);
    for (int i = 0; i < map->capacity; ++i)
        map->entries[i] = NULL;
    return map;
}

static unsigned int entry_index(struct MAP *map, KEY key) {
    return hash(key) % map->capacity;
}

static struct Entry *find_entry(KEY key, struct Entry *entry) {
    while(entry) {
        if (!cmp(key, entry->key))
            return entry;
        entry = entry->next;
    }
    return NULL;
}

VALUE FN(insert)(struct MAP *map, KEY key, VALUE value) {
    int old_capacity = map->capacity;
    if (map->size >= old_capacity * 3 / 4) {
        map->capacity *= 2;
        struct Entry **old = map->entries;
        map->entries = malloc_or_exit(map->capacity * sizeof *map->entries);
        for (int i = 0; i < map->capacity; ++i)
            map->entries[i] = NULL;
        for (int i = 0; i < old_capacity; ++i) {
            struct Entry *entry = old[i];
            if (entry)
                FN(insert)(map, entry->key, entry->value);
        }
        free(old);
    }

    unsigned int index = entry_index(map, key);
    struct Entry *entry = find_entry(key, map->entries[index]);
    if (!entry) {
        entry = malloc_or_exit(sizeof *entry);
        entry->key = key;
        entry->value = value;
        entry->next = map->entries[index];
        map->entries[index] = entry;
        return NIL;
    } else {
        VALUE previous_value = entry->value;
        entry->value = value;
        return previous_value;
    }
}

VALUE FN(lookup)(struct MAP *map, KEY key) {
    unsigned int index = entry_index(map, key);
    struct Entry *entry = find_entry(key, map->entries[index]);
    return entry ? entry->value : NIL;
}

VALUE FN(remove)(struct MAP *map, KEY key) {
    unsigned int index = entry_index(map, key);
    struct Entry **entry = map->entries + index;
    while (*entry) {
        struct Entry *current = *entry;
        if (!cmp(key, current->key)) {
                *entry = current->next;
                VALUE result = current->value;
                free(current);
                return result;
        }
        entry = &current->next;
    }
    return NIL;
}

int FN(size)(struct MAP *map) {
    return map->size;
}

#endif
