%{
    #include<stdio.h>
    #include<stdlib.h>
    void yyerror();
    int yylex();
%}

%union {
    int num;
    float decimal;
    char ch;
    char *string;
}
%start translationunit

%token SWITCH CASE DEFAULT IF ELSE FOR DO WHILE CONTINUE BREAK STRUCT RETURN EQUALS SIZEOF PROLOGIF
%token AND OR ISEQUAL ISNOTEQUAL LE GE SLE SGE DUMMY

%token <ch> SHIFT INC_OR_DEC CHAR
%token <string> TYPE COMP_ASSIGN IDENTIFIER STRING
%token <num> INTEGER
%token <decimal> FLOAT

%%
translationunit : DUMMY;


%%

int main() {
    return yyparse();
}

void yyerror () {
    extern int yylineno;
	printf("Parsing failed at Line %d\nSyntax Error!\n",yylineno);
} 