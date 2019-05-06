%{
#include "y.tab.h"
#include <string.h>

extern int yylval;

int line_number = 1;
%}

%%

"end"   { return END; }
"return"    { return RETURN; }
"var"    { return VAR; }
"cond"    { return COND; }
"continue"    { return CONTINUE; }
"break"    { return BREAK; }
"not"    { return NOT; }
"head"    { return HEAD; }
"tail"    { return TAIL; }
"islist"    { return ISLIST; }
"or"    { return OR; }

";" |
"(" |
")" |
"," |
"=" |
":" |
"+" |
"*" |
"." |
"-" { return yytext[0]; }
"->"    { return GUARD; }
">="    { return GREQ; }

[a-zA-Z][a-zA-Z0-9]* return ID; @{ @ID.name@ = strdup(yytext); @}

[0-9]+ |
\$[0-9a-fA-F]+    { return NUM; }

\{[^\}]*\} ;
[ \t] ;

\n { ++line_number; }

. {
    printf("Lexical error at line %d: %s\n", line_number, yytext);
    exit(1);
}

