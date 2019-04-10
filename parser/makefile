LEX=flex
LDLIBS=-lfl

parser: scanner.o
parser.o: scanner.l parsercode

parsercode: parser.y
	$(YACC) -v -d parser.y 

clean:
	$(RM) *.o parser y.tab.h y.output
