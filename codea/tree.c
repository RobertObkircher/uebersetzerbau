#include "allocation.h"
#include "tree.h"

struct Tree *tree_new_num(long num) {
    struct Tree *result = tree_new(NULL, NULL, TREE_CONST);
    result->num = num;
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
    result->nth_argument = 0;
    result->arg_count = 0;
    result->arg_reg = NULL;
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

struct Tree *tree_new_variable_usage(char *id) {
    struct Tree *result = tree_new(NULL, NULL, TREE_VAR);
    result->id = id;
    return result;
}

struct Tree *tree_new_guard(struct Tree *expr, int guard_uid) {
    struct Tree *result = tree_new(expr, NULL, TREE_GUARD);
    result->guard_uid = guard_uid;
    return result;
}

struct Tree *tree_new_arg(struct Tree *expr, struct Tree *args) {
    struct Tree *result = tree_new(expr, args, TREE_ARG);
    if (args->node_type != TREE_NIL) {
        result->nth_argument = args->nth_argument + 1;
        result->arg_reg = args->arg_reg;
        struct Tree *n = result;
        while(n->node_type != TREE_NIL) { // TODO attribute grammar
            n->arg_count = result->nth_argument;
            n = RIGHT_CHILD(n);
        }
    } else if (expr->node_type != TREE_NIL) {
        result->nth_argument = 1;
        result->arg_count = 1;
        int max_regs = 6;
        result->arg_reg = malloc_or_exit(max_regs * sizeof result->arg_reg);
        for (int i = 0; i < max_regs; ++i) {
            result->arg_reg[i] = REGISTER_NONE;
        }
    }
    return result;
}
