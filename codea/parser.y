%token END RETURN VAR COND CONTINUE BREAK NOT HEAD TAIL ISLIST OR
%token ';' '(' ')' ',' '=' ':' GUARD '+' '*' '.' GREQ '-'
%token ID NUM
%start program

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"
#include "tree.h"

extern int yylex();

extern int line_number;

int yyerror(char *e) {
    printf("Parser error at line %d: %s\n", line_number, e);
    exit(2);
}

%}

@autosyn name sym_up
@autoinh sym

@attributes { long value; } NUM
@attributes { char *name; } ID maybelabeldef 
@attributes { struct Symtab *sym_up; } maybepars pars
@attributes { struct Symtab *sym; } maybestats cond maybeguards guards guarded guard expr nhtis nhti plusterms multterms orterms dotterms gteqeqminus maybeparams params control
@attributes { struct tree *tree; struct Symtab *sym; } term
@attributes { struct Symtab *sym; struct Symtab *sym_up; } stat stats

@traversal symusage

%%

program
    : /* empty */
    |  program funcdef ';'
    ;

funcdef
    : ID '(' maybepars ')' maybestats END
        @{
            @i @maybestats.sym@ = @maybepars.sym_up@;
        @}
    ;

maybepars
    : /* empty */
        @{
            @i @maybepars.sym_up@ = symtab_new();
        @}
    | pars
    ;

pars
    : ID
        @{
            @i @pars.sym_up@ = symtab_new_with_variable(@ID.name@);
        @}
    | pars ',' ID
        @{
            @i @pars.sym_up@ = symtab_variable_declaration(@pars.1.sym_up@, @ID.name@);
        @}
    ;

maybestats
    : /* empty */
    | stats
    ;

stats
    : stat ';'
        @{
            @i @stats.sym_up@ = @stat.sym_up@;
        @}
    | stats stat ';'
        @{
            @i @stat.sym@ = @stats.1.sym_up@;
            @i @stats.sym_up@ = @stat.sym_up@;
        @}
    ;

stat
    : RETURN expr @{ @i @stat.sym_up@ = @stat.sym@; @}
    | cond @{ @i @stat.sym_up@ = @stat.sym@; @}
    | VAR ID '=' expr @{ @i @stat.sym_up@ = symtab_variable_declaration(@stat.sym@, @ID.name@); @}
    | ID '=' expr
        @{
            @i @stat.sym_up@ = symtab_variable_usage(@stat.sym@, @ID.name@);
            // TODO use symusage traversal instead?
        @}
    ;

cond
    : maybelabeldef COND maybeguards END
        @{
            @i @maybeguards.sym@ = symtab_label_declaration(@cond.sym@, @maybelabeldef.name@);
        @}
    ;

maybelabeldef
    : /* empty */
        @{
            @i @maybelabeldef.name@ = NULL;
        @}
    | ID ':'
    ;

maybeguards
    : /* empty */
    | guards
    ;

guards
    : guarded ';'
    | guards guarded ';'
    ;

guarded
    : guard maybestats control
    ;

guard
    : expr GUARD
    | GUARD
    ;

control
    : CONTINUE
    | CONTINUE ID
        @{
            @symusage symtab_label_usage(@control.sym@, @ID.name@);
        @}
    | BREAK
    | BREAK ID
        @{
            @symusage symtab_label_usage(@control.sym@, @ID.name@);
        @}
    ;

expr
    : term
    | nhtis
    | plusterms
    | multterms
    | orterms
    | dotterms
    | term gteqeqminus term
    ;

nhtis
    : nhti term
    | nhti nhtis
    ;

nhti
    : NOT
    | HEAD
    | TAIL
    | ISLIST
    ;

plusterms
    : term '+' term
    | plusterms '+' term
    ;

multterms
    : term '*' term
    | multterms '*' term
    ;

orterms
    : term OR term
    | orterms OR term
    ;

dotterms
    : term '.' term
    | dotterms '.' term
    ;

gteqeqminus
    : GREQ 
    | '='
    | '-'
    ;

term
    : '(' expr ')'
        @{
            @i @term.tree@ = NULL; // TODO
        @}
    | NUM
        @{
            @i @term.tree@ = tree_new_num(@NUM.value@);
        @}
    | ID
        @{
            @symusage symtab_variable_usage(@term.sym@, @ID.name@);
            @i @term.tree@ = NULL; // TODO
        @}
    | ID '(' maybeparams ')'
        @{
            @i @term.tree@ = NULL; // TODO
        @}
    ;

maybeparams
    : /* empty */
    | params
    ;

params
    : expr
    | params ',' expr
    ;

%%
int main(void) {
 yyparse();
 return 0;
}

