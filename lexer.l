
%{
	#include<stdio.h>
	#include <stdlib.h>
	#include"y.tab.h"
%}

%option yylineno
%option noyywrap

%%

"void"|"char"|"short"|"int"|"long"|"float"|"signed"|"unsigned"			{return TYPE;}	
"switch"																{return SWITCH;}
"case"																	{return CASE;}	
"default"																{return DEFAULT;}
"if"																    {return IF;}
"else"																	{return ELSE;}
"for"																	{return FOR;}
"do"																    {return DO;}
"while"																	{return WHILE;}
"continue"																{return CONTINUE;}
"break"																	{return BREAK;}
"struct"|"union"													    {return STRUCT_UNION;}	//*
"return"																{return RETURN;}
"sizeof"																{return SIZEOF;}
"||"                                                                    {return OR;}
"&&"																    {return AND;}  
";"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|"<"|">"|"="|","|"{"|"}"|"("|")"|"["|"]"			{return yytext[0];}
"=="|"!="|"<="|">="|">"|"<"                                             {return COMP;}    
">>"|"<<"																{return SHIFT;}
"++"|"--"																{return INC_OR_DEC;}
// "->"																	{return POINT;}			//*                  
"*="|"/="|"+="|"%="|">>="|"-="|"<<="|"&="|"^="|"|="						{return COMP_ASSIGN;}
[0-9]+																	{return INT;}
[0-9]+"."[0-9]+															{return FLOAT;}	
"'"."'"																	{return CHAR;}
[a-zA-z_][a-zA-z_0-9]*			 										{return IDENTIFIER;}
\"(\\.|[^\"])*\"														{return STRING;}
"//"(\\.|[^\n])*[\n]													;
[/][*]([^*]|[*]*[^*/])*[*]+[/]                                          ;
[ \t\n]																	;  	//might remove the commented rules above
%%

int yywrap(void)
{
    return 1;
}