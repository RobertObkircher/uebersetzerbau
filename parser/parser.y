%token END RETURN VAR COND CONTINUE BREAK NOT HEAD TAIL ISLIST OR
%token ';' '(' ')' ',' '=' ':' GUARD '+' '*' '.' GREQ '-'
%token ID NUM
%start program

%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();

int yyerror(char *e) {
 printf("Parser error: '%s'...\n", e);
 exit(2);
}

%}

%%

program
    : /* empty */
    |  program funcdef ';'
    ;

funcdef
    : ID '(' maybepars ')' maybestats END
    ;

maybepars
    : /* empty */
    | pars
    ;

pars
    : ID
    | pars ',' ID
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
    : guard stats control
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
    | nhtis term
    | plusterms
    | multterms
    | orterms
    | dotterms
    | term gteqeqminus term
    ;

nhtis
    : nhti
    | nhti nhtis
    ;

nhti
    : NOT
    | HEAD
    | TAIL
    | ISLIST
    ;

plusterms
    : term
    | plusterms '+' term
    ;

multterms
    : term
    | multterms '*' term
    ;

orterms
    : term
    | orterms OR term
    ;

dotterms
    : term
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

