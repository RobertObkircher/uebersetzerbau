#include "allocation.h"
#include "tree.h"

struct Tree *tree_new_num(long num) {
    struct Tree *result = tree_new(NULL, NULL, TREE_CONST);
    result->num = num;
    return result;
}

struct Tree *tree_new_id(char *id) {
    struct Tree *result = tree_new(NULL, NULL, TREE_VAR);
    result->id = id;
    return result;
}

struct Tree *tree_new(struct Tree *left, struct Tree *right, enum Type type) {
    struct Tree *result = malloc_or_exit(sizeof *result);
    result->node_type = type;
    result->kids[0] = left;
    result->kids[1] = right;
    result->reg = REGISTER_NONE;
    result->num = 0;
    result->id = NULL;
    result->state = NULL;
    result->guard_uid = 0;
    return result;
}

struct Tree *tree_nil() {
    return tree_new(NULL, NULL, TREE_NIL);
}

struct Tree *tree_new_variable_assignment(char *name, struct Tree *expr) {
    struct Tree *result = tree_new(expr, NULL, TREE_ASSIGN);
    result->id = name;
    return result;
}

struct Tree *tree_new_variable_declaration(char *name, struct Tree *expr) {
    struct Tree *result = tree_new(expr, NULL, TREE_DECL);
    result->id = name;
    return result;
}

struct Tree *tree_new_guard(struct Tree *expr, int guard_uid) {
    struct Tree *result = tree_new(expr, NULL, TREE_GUARD);
    result->guard_uid = guard_uid;
    return result;
}
