parser : lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o parser

lex.yy.c : y.tab.c lexer.l
	flex lexer.l

y.tab.c : parser.y
	bison -d parser.y

clean : 
	rm -rf parser.dSYM parser lex.yy.c y.tab.c y.tab.h
