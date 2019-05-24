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

extern void invoke_burm(NODEPTR_TYPE root, char *fn_name, struct Symtab *params);

%}

@autosyn name sym_up
@autoinh sym

@attributes { long value; } NUM
@attributes { char *name; } ID maybelabeldef 
@attributes { struct Symtab *sym_up; } maybepars pars
@attributes { struct Symtab *sym; } cond maybeguards guards guarded guard multterms orterms dotterms gteqeqminus maybeparams params control
@attributes { struct Tree *tree; struct Symtab *sym; } term maybestats expr nhtis plusterms 
@attributes { struct Tree *tree; struct Symtab *sym; struct Symtab *sym_up; } stat stats
@attributes { int node_type; } nhti 

@traversal symusage
@traversal @preorder codegen

%%

program
    : /* empty */
    |  program funcdef ';'
    ;

funcdef
    : ID '(' maybepars ')' maybestats END
        @{
            @i @maybestats.sym@ = symtab_new_clone(@maybepars.sym_up@);
            @codegen invoke_burm(@maybestats.tree@, @ID.name@, @maybepars.sym_up@);
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
        @{
            @i @maybestats.tree@ = tree_nil();
        @}
    | stats
        @{
            @i @maybestats.tree@ = @stats.tree@; // TODO autosyn
        @}
    ;

stats
    : stat ';'
        @{
            @i @stats.sym_up@ = @stat.sym_up@;
            @i @stats.tree@ = tree_new(@stat.tree@, tree_nil(), TREE_STATS); // TODO autosyn
        @}
    | stats stat ';'
        @{
            @i @stat.sym@ = @stats.1.sym_up@;
            @i @stats.sym_up@ = @stat.sym_up@;
            @i RIGHT_CHILD(@stats.tree@) = tree_new(@stat.tree@, tree_nil(), TREE_STATS);
        @}
    ;

stat
    : RETURN expr
        @{
            @i @stat.sym_up@ = @stat.sym@;
            @i @stat.tree@ = tree_new(@expr.tree@, NULL, TREE_RETURN);
        @}
    | cond
        @{
            @i @stat.sym_up@ = @stat.sym@;
            @i @stat.tree@ = NULL; // TODO
        @}
    | VAR ID '=' expr 
        @{ 
            @i @stat.sym_up@ = symtab_variable_declaration(@stat.sym@, @ID.name@); 
            @i @stat.tree@ = NULL; // TODO
        @}
    | ID '=' expr
        @{
            // TODO use symusage traversal instead?
            @i @stat.sym_up@ = symtab_variable_usage(@stat.sym@, @ID.name@);
            @i @stat.tree@ = NULL; // TODO
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
        @{
            @i @expr.tree@ = @term.tree@;
        @}
    | nhtis
        @{
            @i @expr.tree@ = @nhtis.tree@; // TODO autosyn
        @}
    | plusterms
        @{
            @i @expr.tree@ = @plusterms.tree@; // TODO autosyn
        @}
    | multterms
        @{
            @i @expr.tree@ = NULL;
        @}
    | orterms
        @{
            @i @expr.tree@ = NULL;
        @}
    | dotterms
        @{
            @i @expr.tree@ = NULL;
        @}
    | term gteqeqminus term
        @{
            @i @expr.tree@ = NULL;
        @}
    ;

nhtis
    : nhti term
        @{
            @i @nhtis.tree@ = tree_new(@term.tree@, NULL, @nhti.node_type@);
        @}
    | nhti nhtis
        @{
            @i @nhtis.tree@ = tree_new(@nhtis.1.tree@, NULL, @nhti.node_type@);
        @}
    ;

nhti
    : NOT @{ @i @nhti.node_type@ = TREE_NOT; @}
    | HEAD @{ @i @nhti.node_type@ = TREE_HEAD; @}
    | TAIL @{ @i @nhti.node_type@ = TREE_TAIL; @}
    | ISLIST @{ @i @nhti.node_type@ = TREE_ISLIST; @}
    ;

plusterms
    : term '+' term
        @{
            @i @plusterms.tree@ = tree_new(@term.tree@, @term.1.tree@, TREE_ADDITION);
        @}
    | plusterms '+' term
        @{
            @i @plusterms.tree@ = tree_new(@plusterms.1.tree@, @term.tree@, TREE_ADDITION);
        @}
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
            @i @term.tree@ = @expr.tree@;
        @}
    | NUM
        @{
            @i @term.tree@ = tree_new_num(@NUM.value@);
        @}
    | ID
        @{
            @symusage symtab_variable_usage(@term.sym@, @ID.name@);
            @i @term.tree@ = tree_new_id(@ID.name@);
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

