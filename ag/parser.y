%token END RETURN VAR COND CONTINUE BREAK NOT HEAD TAIL ISLIST OR
%token ';' '(' ')' ',' '=' ':' GUARD '+' '*' '.' GREQ '-'
%token ID NUM
%start program

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

extern int yylex();

extern int line_number;

int yyerror(char *e) {
    printf("Parser error at line %d: %s\n", line_number, e);
    exit(2);
}
%}

@attributes { char *name; } ID
@attributes { @autoinh struct Symtab *sym; } funcdef

/*
@traversal @preorder symtab
*/

%%

program
    : /* empty */
    |  program funcdef ';' @{
        @i @funcdef.sym@ = symtab_new(@ID.name@);
    @}
    ;

funcdef
    : ID '(' maybepars ')' maybestats END
    ;

maybepars
    : /* empty */
    | pars
    ;

pars
    : ID @{
    /*
        @symtab symtab_variable_declaration(@pars.sym@, @ID.name@);
        */
    @}
    | pars ',' ID @{
    /*
        @symtab symtab_variable_declaration(@pars.sym@, @ID.name@);
        */
    @}
    ;

maybestats
    : /* empty */
    | stats
    ;

stats
    : stat ';'
    | stats stat ';'
    ;

stat
    : RETURN expr
    | cond
    | VAR ID '=' expr
    | ID '=' expr
    ;

cond
    : maybelabeldef COND maybeguards END
    ;

maybelabeldef
    : /* empty */
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
    | BREAK
    | BREAK ID
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
    | NUM
    | ID
    | ID '(' maybeparams ')'
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

