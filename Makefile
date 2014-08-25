CXX=cc

lexsy:	lexsy.l lexsy.y
		bison -d lexsy.y
		flex lexsy.l
		$(CXX) -o myParser lexsy.tab.c lex.yy.c -lfl

.PHONY:	clean

clean:
	rm -f myParser *.c *.h
