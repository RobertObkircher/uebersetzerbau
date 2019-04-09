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
    :
    ;

%%
int main(void) {
 yyparse();
 return 0;
}

