
%%

"end" |
"return" |
"var" |
"cond" |
"continue" |
"break" |
"not" |
"head" | 
"tail" |
"islist" |
"or" {printf("%s\n", yytext);}

";" |
"(" |
")" |
"," |
"=" |
":" |
"->" |
"+" |
"*" |
"." |
">=" |
"-" {printf("%s\n", yytext);}

[a-zA-Z][a-zA-Z0-9]* {printf("id %s\n", yytext);}

[0-9]+ {printf("num %ld\n", atol(yytext));}
\$[0-9a-fA-F]+ {printf("num %ld\n", strtol(yytext + 1, 0, 16));}

\{[^\}]*\} ;
[ \t\n] ;

. printf("Lexical error.\n"); exit(1);
