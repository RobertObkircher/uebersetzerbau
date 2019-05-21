#include "allocation.h"
#include "tree.h"

struct Tree *tree_new_num(long num) {
    struct Tree *result = malloc_or_exit(sizeof *result);
    result->node_type = TREE_CONST;
    result->num = num;
    return result;
}

struct Tree *tree_new_id(char *id) {
    struct Tree *result = malloc_or_exit(sizeof *result);
    result->node_type = TREE_VAR;
    result->id = id;
    return result;
}

struct Tree *tree_new(struct Tree *left, struct Tree *right, enum Type type) {
    struct Tree *result = malloc_or_exit(sizeof *result);
    result->kids[0] = left;
    result->kids[1] = right;
    result->node_type = type;
    return result;
}

struct Tree *tree_nil() {
    return tree_new(NULL, NULL, TREE_NIL);
}
