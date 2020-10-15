
%{
	#include<stdio.h>
	#include <stdlib.h>
	#include"y.tab.h"
%}

%option yylineno
%option noyywrap

%%

"void"|"char"|"int"|"float"|"bool"|"string"																				{yylval.string = yytext; return TYPE;}	
"switch"																														{return SWITCH;}
"case"																															{return CASE;}	
"default"																														{return DEFAULT;}
"if"																    														{return IF;}
"else"																															{return ELSE;}
"for"																															{return FOR;}
"do"																    														{return DO;}
"while"																															{return WHILE;}
"continue"																														{return CONTINUE;}
"break"																															{return BREAK;}
"struct"													    																{return STRUCT;}
"return"																														{return RETURN;}
"sizeof"																														{return SIZEOF;}
"plif"																															{return PROLOGIF;}
"||"                                                                    														{return OR;}
"&&"																    														{return AND;}
"=="																															{return ISEQUAL;}
"!="																															{return ISNOTEQUAL;}
"<="																															{return LE;}
">="																															{return GE;}
"<"																																{return SLE;}
">"																																{return SGE;}
">>"|"<<"																														{yylval.ch = yytext[0]=='<' ? 'l' : 'r'; return SHIFT;}
"++"|"--"																														{yylval.ch = yytext[0]=='+' ? 'a' : 's'; return INC_OR_DEC;}
";"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|","|"{"|"}"|"("|")"|"["|"]"													{return yytext[0];}
"*="|"/="|"+="|"%="|">>="|"-="|"<<="|"&="|"^="|"|="|"="|"is"																	{yylval.string = yytext; return ASGN_OPERATOR;}
"true"|"false"																													{yylval.ch = yytext[0]; return BOOL_CONST;}
[0-9]+																															{yylval.num = atoi(yytext); return INTEGER;}
[0-9]+"."[0-9]+																													{yylval.decimal = atof(yytext); return FLOAT;}	
"'"."'"																															{yylval.ch = yytext[1]; return CHAR;}
[a-zA-z_][a-zA-z_0-9]*			 																								{yylval.string = yytext; return IDENTIFIER;}
\"(\\.|[^\"])*\"																												{yylval.string = yytext; return STRING;}
"//"(\\.|[^\n])*[\n]																											{;}
[/][*]([^*]|[*]*[^*/])*[*]+[/]                                          														{;}
[ \t\n]																															{;}

%%

