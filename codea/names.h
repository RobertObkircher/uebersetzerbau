#ifndef __NAMES_H__
#define __NAMES_H__

#include "asm.h"

void push_label(char *name, int cond_uid);
int lookup_label_cond_uid(char *name);
void pop_label();

void push_variable(char *name, enum Register reg);
void set_variable_reg(char *name, enum Register reg);
enum Register lookup_variable_reg(char *name);
enum Register pop_variable();

#endif
