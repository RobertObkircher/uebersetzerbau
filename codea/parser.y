%token END RETURN VAR COND CONTINUE BREAK NOT HEAD TAIL ISLIST OR
%token ';' '(' ')' ',' '=' ':' GUARD '+' '*' '.' GE '-'
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

void codegen_begin_function(char *fn_name, struct Symtab *params);
void codegen_end_function();
void codegen_empty_function();
void codegen_statement(NODEPTR_TYPE root);

%}

@autosyn name sym_up tree
@autoinh sym

@attributes { long value; } NUM
@attributes { char *name; } ID maybelabeldef 
@attributes { struct Symtab *sym_up; } maybepars pars
@attributes { struct Symtab *sym; } cond maybeguards guards guarded guard maybeparams params control maybestats 
@attributes { struct Tree *tree; struct Symtab *sym; } term expr nhtis plusterms multterms orterms dotterms 
@attributes { struct Symtab *sym; struct Symtab *sym_up; } stats
@attributes { struct Tree *tree; struct Symtab *sym; struct Symtab *sym_up; } stat
@attributes { int node_type; } nhti geeqsub 

@traversal symusage
@traversal @postorder codegen

%%

program
    : /* empty */
    |  program funcdef ';'
    ;

funcdef
    : ID '(' maybepars ')' maybestats END
        @{
            @i @maybestats.sym@ = symtab_new_clone(@maybepars.sym_up@);
            @codegen @revorder(1) codegen_begin_function(@ID.name@, @maybepars.sym_up@);
            @codegen codegen_end_function();
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
            @codegen codegen_empty_function();
        @}
    | stats
    ;

stats
    : stat ';'
        @{
            @i @stats.sym_up@ = @stat.sym_up@;
            @codegen codegen_statement(@stat.tree@);
        @}
    | stats stat ';'
        @{
            @i @stat.sym@ = @stats.1.sym_up@;
            @i @stats.sym_up@ = @stat.sym_up@;
            @codegen codegen_statement(@stat.tree@);
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
    | nhtis
    | plusterms
    | multterms
    | orterms
    | dotterms
    | term geeqsub term
        @{
            @i @expr.tree@ = tree_new(@term.tree@, @term.1.tree@, @geeqsub.node_type@);
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
    : NOT    @{ @i @nhti.node_type@ = TREE_NOT;    @}
    | HEAD   @{ @i @nhti.node_type@ = TREE_HEAD;   @}
    | TAIL   @{ @i @nhti.node_type@ = TREE_TAIL;   @}
    | ISLIST @{ @i @nhti.node_type@ = TREE_ISLIST; @}
    ;

plusterms
    : term '+' term
        @{
            @i @plusterms.tree@ = tree_new(@term.tree@, @term.1.tree@, TREE_ADD);
        @}
    | plusterms '+' term
        @{
            @i @plusterms.tree@ = tree_new(@plusterms.1.tree@, @term.tree@, TREE_ADD);
        @}
    ;

multterms
    : term '*' term
        @{
            @i @multterms.tree@ = tree_new(@term.tree@, @term.1.tree@, TREE_MUL);
        @}
    | multterms '*' term
        @{
            @i @multterms.tree@ = tree_new(@multterms.1.tree@, @term.tree@, TREE_MUL);
        @}
    ;

orterms
    : term OR term
        @{
            @i @orterms.tree@ = tree_new(@term.tree@, @term.1.tree@, TREE_OR);
        @}
    | orterms OR term
        @{
            @i @orterms.tree@ = tree_new(@orterms.1.tree@, @term.tree@, TREE_OR);
        @}
    ;

dotterms
    : term '.' term
        @{
            @i @dotterms.tree@ = tree_new(@term.tree@, @term.1.tree@, TREE_CONS);
        @}
    | term '.' dotterms
        @{
            @i @dotterms.tree@ = tree_new(@term.tree@, @dotterms.1.tree@, TREE_CONS);
        @}
    ;

geeqsub
    : GE  @{ @i @geeqsub.node_type@ = TREE_GE;  @}
    | '=' @{ @i @geeqsub.node_type@ = TREE_EQ;  @}
    | '-' @{ @i @geeqsub.node_type@ = TREE_SUB; @}
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

