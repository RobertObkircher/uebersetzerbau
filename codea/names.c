#include "allocation.h"
#include "names.h"
#include "panic.h"
#include "stdbool.h"
#include "stdlib.h"
#include "string.h"

#define MAX_NAMES 1024

static int next_unique_label = 1;

struct Label {
    char *name_in_code;
    int cond_uid;
};
static int label_count;
static struct Label labels[MAX_NAMES];

struct Variable {
    char *name;
    enum Register reg;
};
static int variable_count;
static struct Variable variables[MAX_NAMES];

static void check_label_unknown(char *name, const char *message) {
    for (int i = 0; i < label_count; ++i) {
        if (!strcmp(name, labels[i].name_in_code)) {
            panic3("%s: %s", message, name);
        }
    }
}

static void check_variable_unknown(char *name, const char *message) {
    for (int i = 0; i < variable_count; ++i) {
        if (!strcmp(name, variables[i].name)) {
            panic3("%s: %s", message, name);
        }
    }
}

void push_label(char *name, int cond_uid) {
    check_label_unknown(name, "duplicate label");
    check_variable_unknown(name, "variable with same name as label");
    if (label_count >= MAX_NAMES)
        panic("too many labels!");

    struct Label *label = labels + label_count++;
    label->name_in_code = name;
    label->cond_uid = cond_uid;
}

int lookup_label_cond_uid(char *name) {
    for (int i = 0; i < label_count; ++i) {
        if (!strcmp(name, labels[i].name_in_code)) {
            return labels[i].cond_uid;
        }
    }
    panic3("unknown label: %s", name);
}

void pop_label() {
    if (label_count <= 0)
        panic("no label to pop");
    struct Label *label = labels + --label_count;
}

void push_variable(char *name, enum Register reg) {
    check_label_unknown(name, "label with same name as variable");
    check_variable_unknown(name, "duplicate variable");
    if (variable_count >= MAX_NAMES)
        panic("too many variables!");

    struct Variable *variable = variables + variable_count++;
    variable->name = name;
    variable->reg = reg;
}

void set_variable_reg(char *name, enum Register reg) {
    for (int i = 0; i < variable_count; ++i) {
        if (!strcmp(name, variables[i].name)) {
            variables[i].reg = reg;
            return;
        }
    }
    panic3("unknown variable: %s", name);
}

enum Register lookup_variable_reg(char *name) {
    for (int i = 0; i < variable_count; ++i) {
        if (!strcmp(name, variables[i].name)) {
            return variables[i].reg;
        }
    }
    panic3("unknown variable: %s", name);
}

enum Register pop_variable() {
    if (variable_count <= 0)
        panic("no variable to pop");
    struct Variable *variable = variables + --variable_count;
    return variable->reg;
}
