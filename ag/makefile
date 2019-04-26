LEX=flex
LDLIBS=-lfl

ag: parser
	mv parser ag

parser: scanner.o
parser.o: scanner.l parsercode

parsercode: parser.y
	$(YACC) -v -d parser.y 

clean:
	$(RM) *.o ag y.tab.h y.output
