#ifndef SYMTAB_H
#define SYMTAB_H

struct Symtab;

struct Symtab *symtab_new();
struct Symtab *symtab_new_with_variable(char *name);
struct Symtab *symtab_new_clone(struct Symtab *symtab);

struct Symtab *symtab_variable_declaration(struct Symtab *symtab, char *name);
struct Symtab *symtab_variable_usage(struct Symtab *symtab, char *name);

struct Symtab *symtab_label_declaration(struct Symtab *symtab, char *name);
struct Symtab *symtab_label_usage(struct Symtab *symtab, char *name);

int symtab_size(struct Symtab *symtab);

void symtab_foreach_variable(struct Symtab *symtab, void(*iter)(char *key));

#endif
