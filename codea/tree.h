#ifndef __TREE_H__
#define __TREE_H__

#include <stdbool.h>
#include "asm.h"

struct Tree {
    int node_type;
    struct Tree *kids[2];
    
    enum Register reg;
    long num;
    char *id;
    int cond_uid;
    int guard_uid;
    
    struct burm_state* state;       /* state variable for BURG */
};

#define NODEPTR_TYPE struct Tree*
#define LEFT_CHILD(p) ((p)->kids[0])
#define RIGHT_CHILD(p) ((p)->kids[1])
#define PANIC printf
#define STATE_LABEL(p) ((p)->state)
#define OP_LABEL(p) ((p)->node_type)


#define TREE_NODE_CONST 1
#define TREE_NODE_VAR 1


enum Type {
    TREE_CONST = 1,
    TREE_VAR,

    // binary:
    TREE_ADD,
    TREE_SUB,
    TREE_MUL,
    TREE_CONS,
    TREE_GE,
    TREE_EQ,
    TREE_OR,

    // unary:
    TREE_NOT,
    TREE_ISLIST,
    TREE_HEAD,
    TREE_TAIL,

    TREE_RETURN, // (expr, NULL)                
    TREE_EXPR, // binary or unary

    TREE_NIL,
    
    TREE_DECL,
    TREE_ASSIGN,

    TREE_GUARD,
};

struct Tree *tree_new_num(long num);
struct Tree *tree_new(struct Tree *left, struct Tree *right, enum Type type);
struct Tree *tree_nil();
struct Tree *tree_new_variable_assignment(char *name, struct Tree *expr);
struct Tree *tree_new_variable_declaration(char *name, struct Tree *expr);
struct Tree *tree_new_variable_usage(char *id);
struct Tree *tree_new_guard(struct Tree *expr, int guard_uid);

#endif
