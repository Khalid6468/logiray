parser : lexer.cpp parser.cpp
	g++ -g lexer.cpp parser.cpp -o parser

lexer.cpp : parser.cpp lexer.l
	flex -o lexer.cpp lexer.l

parser.cpp : parser.y
	bison -d -o parser.cpp parser.y

clean : 
	rm parser lexer.cpp parser.cpp parser.hpp
