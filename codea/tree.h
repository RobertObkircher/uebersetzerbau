#ifndef __TREE_H__
#define __TREE_H__

enum Register {
    /*caller saved*/
    RAX = 0,
    RCX, /* 4 */
    RDX, /* 3 */
    RSI, /* 2 */
    RDI, /* 1 */
    R8,  /* 5 */
    R9,  /* 6 */
    R10,
    R11,
    REG_COUNT,
};


typedef struct tree {
	int op;                    /* node type */
	struct tree *kids[2];      /* successor nodes */
	                           /* attributes of node (depending on type) */
      	enum Register reg;
       	long num;
        char *id;                  /* variable name */
        struct burm_state* state;       /* state variable for BURG */
} *NODEPTR_TYPE, *Tree;

#define LEFT_CHILD(p) ((p)->kids[0])
#define RIGHT_CHILD(p) ((p)->kids[1])
#define PANIC printf
#define STATE_LABEL(p) ((p)->state)
#define OP_LABEL(p) ((p)->op)

enum Type {
    TREE_CONST = 1,
    TREE_VAR,

    TREE_ADDITION,
    TREE_SUBTRACTION,
    TREE_MULTIPLICATION,
    TREE_CONS,
    TREE_NOT_LESS,
    TREE_EQUAL,
    TREE_OR,
    TREE_NOT,
    TREE_ISLIST,
    TREE_HEAD,
    TREE_TAIL,
};

struct tree* tree_new_num(long num);

#endif
