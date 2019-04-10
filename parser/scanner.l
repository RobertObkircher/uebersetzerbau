%{
#include "y.tab.h"
extern int yylval;
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

";" ;
"(" ;
")" ;
"," ;
"=" ;
":" ;
"->"    { return GUARD; }
"+" ;
"*" ;
"." ;
">="    { return GREQ; }
"-" ;

[a-zA-Z][a-zA-Z0-9]*    { return ID; }

[0-9]+ |
\$[0-9a-fA-F]+    { return NUM; }

\{[^\}]*\} ;
[ \t\n] ;

.    { printf("Lexical error.\n"); exit(1); }

