CFLAGS = -DEBUG -g

codea: y.tab.c y.tab.h lex.yy.c symtab.o symmap.o regmap.o tree.o allocation.o codegen.o asm.o panic.o
	$(CC) -o codea y.tab.h y.tab.c lex.yy.c *.o -lfl

oxout.y oxout.l: parser.y scanner.l
	ox parser.y scanner.l

y.tab.c y.tab.h: oxout.y
	yacc -d oxout.y

lex.yy.c: oxout.l y.tab.h symtab.o symmap.o allocation.o
	lex oxout.l

symtab.o: symtab.c symmap.h
symmap.o: symmap.c symmap.h map.h
regmap.o: regmap.c regmap.h map.h
tree.o: tree.c tree.h
asm.o: asm.c asm.h
allocation.o: allocation.c allocation.h
panic.o: panic.c panic.h

codegen.brg: codegen.bfe
	bfe codegen.bfe > codegen.brg
codegen.c: codegen.brg
	iburg codegen.brg > codegen.c
codegen.o: codegen.c

clean:
	$(RM) *.o ag y.tab.h y.tab.c lex.yy.c oxout.l oxout.y *.brg codegen.c
