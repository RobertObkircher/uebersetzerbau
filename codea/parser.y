%token END RETURN VAR COND CONTINUE BREAK NOT HEAD TAIL ISLIST OR
%token ';' '(' ')' ',' '=' ':' GUARD '+' '*' '.' GE '-'
%token ID NUM
%start program

%{
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"
#include "names.h"

extern int yylex();

extern int line_number;

int yyerror(char *e) {
    printf("Parser error at line %d: %s\n", line_number, e);
    exit(2);
}

void codegen_begin_function(char *fn_name);
void codegen_add_param(char *name);
void codegen_end_function(bool empty);
void codegen_empty_function();
void codegen_statement(NODEPTR_TYPE root);
void codegen_free_variables(int var_count);

static int next_unique_id = 1;
%}

@autosyn name tree
@autoinh cond_uid

@attributes { long value; } NUM
@attributes { char *name; } ID
@attributes {  } maybepars pars
@attributes {  } maybeparams params
@attributes { int empty; } maybestats 
@attributes {  int cond_uid; } cond maybeguards guards guarded control 
@attributes {  int cond_uid; int guard_uid; } guard
@attributes { struct Tree *tree;  } term expr nhtis plusterms multterms orterms dotterms 
@attributes {  int var_count; } stats
@attributes { struct Tree *tree; int var_count; } stat
@attributes { int node_type; } nhti geeqsub 

@traversal @lefttoright @postorder codegen

%%

program
    : /* empty */
    |  program funcdef ';'
    ;

funcdef
    : ID '(' maybepars ')' maybestats END
        @{
            @codegen @revorder(1) codegen_begin_function(@ID.name@);
            @codegen codegen_end_function(@maybestats.empty@);
        @}
    ;

maybepars
    : /* empty */
    | pars
    ;

pars
    : ID
        @{
            @codegen codegen_add_param(@ID.name@);
        @}
    | pars ',' ID
        @{
            @codegen codegen_add_param(@ID.name@);
        @}
    ;

maybestats
    : /* empty */
        @{
            @i @maybestats.empty@ = true;
        @}
    | stats
        @{
            @i @maybestats.empty@ = false;
            @codegen codegen_free_variables(@stats.var_count@);
        @}
    ;

stats
    : stat ';'
        @{
            @i @stats.var_count@ = @stat.var_count@;
        @}
    | stats stat ';'
        @{
            @i @stats.var_count@ = @stats.1.var_count@ + @stat.var_count@;
        @}
    ;

stat
    : RETURN expr
        @{
            @i @stat.tree@ = tree_new(@expr.tree@, NULL, TREE_RETURN);
            @i @stat.var_count@ = 0;
            @codegen codegen_statement(@stat.tree@);
        @}
    | cond
        @{
            @i @cond.cond_uid@ = next_unique_id++;
            @i @stat.tree@ = NULL;
            @i @stat.var_count@ = 0;
            @codegen @revorder(1) printf(".C%d:\n", @cond.cond_uid@);
            @codegen printf(".E%d:\n", @cond.cond_uid@);
        @}
    | VAR ID '=' expr 
        @{ 
            @i @stat.tree@ = tree_new_variable_declaration(@ID.name@, @expr.tree@);
            @i @stat.var_count@ = 1;
            @codegen {
                codegen_statement(@stat.tree@);
                lookup_variable_reg(@ID.name@); // Just to be sure
            }
        @}
    | ID '=' expr
        @{
            @i @stat.tree@ = tree_new_variable_assignment(@ID.name@, @expr.tree@);
            @i @stat.var_count@ = 0;
            @codegen {
                lookup_variable_reg(@ID.name@); // codegen_statement should call this anyway
                codegen_statement(@stat.tree@);
            }
        @}
    ;

cond
    : COND maybeguards END
    | ID ':' COND maybeguards END
        @{
            @codegen @revorder(1) push_label(@ID.name@, @cond.cond_uid@);
            @codegen pop_label();
        @}
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
        @{
            @i @guard.guard_uid@ = next_unique_id++;
            @codegen printf(".G%d:\n", @guard.guard_uid@);
        @}
    ;

guard
    : expr GUARD
        @{
            @codegen @revorder(1) codegen_statement(tree_new_guard(@expr.tree@, @guard.guard_uid@));
        @}
    | GUARD
    ;

control
    : CONTINUE
        @{
            @codegen printf("\tjmp .C%d\n", @control.cond_uid@);
        @}
    | CONTINUE ID
        @{
            @codegen {
                int uid = lookup_label_cond_uid(@ID.name@);
                printf("\tjmp .C%d\n", uid);
            }
        @}
    | BREAK
        @{
            @codegen printf("\tjmp .E%d\n", @control.cond_uid@);
        @}
    | BREAK ID
        @{
            @codegen {
                int uid = lookup_label_cond_uid(@ID.name@);
                printf("\tjmp .E%d\n", uid);
            }
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
    | NUM
        @{
            @i @term.tree@ = tree_new_num(@NUM.value@);
        @}
    | ID
        @{
            @codegen lookup_variable_reg(@ID.name@); // codegen_statement should call this anyway
            @i @term.tree@ = tree_new_variable_usage(@ID.name@);
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

