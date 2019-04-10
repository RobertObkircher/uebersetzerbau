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
    : ID '(' pars ')' stats END
    | ID '(' ')' stats END
    ;

pars
    : ID
    | pars ',' ID
    ;

stats
    : /* empty */
    | stats stat ';'
    ;

stat
    : RETURN expr
    | cond
    | VAR ID '=' expr
    | ID '=' expr
    ;

cond
    : label COND guards END
    | COND guards END
    ;

label
    : ID ':'
    ;

guards
    : /* empty */
    | guards guarded ';'
    ;

guarded
    : expr GUARD stats
    | GUARD stats
    | CONTINUE
    | CONTINUE ID
    | BREAK
    | BREAK ID
    ;

expr
    : NOT term
    | HEAD term
    | TAIL term
    | ISLIST term
    | plusterms
    | multterms
    | orterms
    | dotterms
    | term gteqeqminus term
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
    | ID '(' params ')'
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

