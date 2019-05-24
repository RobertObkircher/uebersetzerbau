%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>

extern int yylval;

int line_number = 1;
%}

%%

"end"       return END;
"return"    return RETURN;
"var"       return VAR;
"cond"      return COND;
"continue"  return CONTINUE;
"break"     return BREAK;
"not"       return NOT;
"head"      return HEAD;
"tail"      return TAIL;
"islist"    return ISLIST;
"or"        return OR;
"->"        return GUARD;
">="        return GE;
";"         return ';';
"("         return '(';
")"         return ')';
","         return ',';
"="         return '=';
":"         return ':';
"+"         return '+';
"*"         return '*';
"."         return '.';
"-"         return '-';

[a-zA-Z][a-zA-Z0-9]* return ID; @{ @ID.name@ = strdup(yytext); @}

[0-9]+         return NUM; @{ @NUM.value@ = atol(yytext); @}
\$[0-9a-fA-F]+ return NUM; @{ @NUM.value@ = strtoul(yytext + 1, 0, 16); @}

\{[^\}]*\} ;
[ \t] ;

\n { ++line_number; }

. {
    printf("Lexical error at line %d: %s\n", line_number, yytext);
    exit(1);
}

