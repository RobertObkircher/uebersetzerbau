#include "allocation.h"
#include "tree.h"

struct tree* tree_new_num(long num) {
    struct tree* result = malloc_or_exit(sizeof *result);
    result->op = TREE_CONST;
    result->num = num;
    return result;
}
