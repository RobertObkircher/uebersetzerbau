ag: y.tab.c y.tab.h lex.yy.c
	gcc -o ag y.tab.h y.tab.c lex.yy.c -lfl

oxout.y oxout.l: parser.y scanner.l
	ox parser.y scanner.l

y.tab.c y.tab.h: oxout.y
	yacc -d oxout.y

lex.yy.c: oxout.l y.tab.h
	lex oxout.l

symtab.o: symtab.c symmap.h
symmap.o: symmap.c symmap.h map.h
allocation.o: allocation.c allocation.h

clean:
	$(RM) *.o ag y.tab.h y.tab.c lex.yy.c oxout.l oxout.y
