#ifndef SYMTAB_H
#define SYMTAB_H

struct Symtab;

struct Symtab* symtab_new();

void symtab_enter_scope(struct Symtab *symtab);
void symtab_leave_scope(struct Symtab *symtab);

void symtab_variable_declaration(struct Symtab *symtab, char *name);
void symtab_variable_usage(struct Symtab *symtab, char *name);

void symtab_label_declaration(struct Symtab *symtab, char *name);
void symtab_label_usage(struct Symtab *symtab, char *name);

#endif
