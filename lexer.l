UCN     (\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})

%option yylineno
%x INCLFILE

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "parser.tab.h"
	char* curfilename;
	void newfile(char* fn);
    extern char* fname;
    YY_BUFFER_STATE include_stack[1000];
    int include_stack_ptr = 0;
%}

%%

"void"|"char"|"int"|"float"|"bool"|"string"					   	                                {yylval.string = yytext; printf("%s\t\t\t - \t TYPE\n", yytext); return TYPE;}	
"switch"														                                {printf("%s\t\t\t - \t SWITCH\n", yytext); return SWITCH;}
"case"															                                {printf("%s\t\t\t - \t CASE\n", yytext); return CASE;}	
"default"														                                {printf("%s\t\t\t - \t DEFAULT\n", yytext); return DEFAULT;}
"if"															                                {printf("%s\t\t\t - \t IF\n", yytext); return IF;}
"else"															                                {printf("%s\t\t\t - \t ELSE\n", yytext); return ELSE;}
"for"															                                {printf("%s\t\t\t - \t FOR\n", yytext); return FOR;}
"do"															                                {printf("%s\t\t\t - \t DO\n", yytext); return DO;}
"while"															                                {printf("%s\t\t\t - \t WHILE\n", yytext); return WHILE;}
"continue"														                                {printf("%s\t\t\t - \t CONTINUE\n", yytext); return CONTINUE;}
"break"															                                {printf("%s\t\t\t - \t BREAK\n", yytext); return BREAK;}
"struct"													                                    {printf("%s\t\t\t - \t STRUCT\n", yytext); return STRUCT;}
"import"                                                                                        {BEGIN(INCLFILE);}
"return"														                                {printf("%s\t\t\t - \t RETURN\n", yytext); return RETURN;}
"sizeof"														                                {printf("%s\t\t\t - \t SIZEOF\n", yytext); return SIZEOF;}
"plif"|":-"															                            {printf("%s\t\t\t - \t PROLOGIF\n", yytext); return PROLOGIF;}
"||"                                                                                            {printf("%s\t\t\t - \t OR\n", yytext); return OR;}
"&&"															                                {printf("%s\t\t\t - \t AND\n", yytext); return AND;}
"=="|"is"														                                {printf("%s\t\t\t - \t ISEQUAL\n", yytext); return ISEQUAL;}
"!="|"isnot"													                                {printf("%s\t\t\t - \t ISNOTEQUAL\n", yytext); return ISNOTEQUAL;}
"<="															                                {printf("%s\t\t\t - \t LE\n", yytext); return LE;}
">="															                                {printf("%s\t\t\t - \t GE\n", yytext); return GE;}
"<"																                                {printf("%s\t\t\t - \t SLE\n", yytext); return SLE;}
">"																                                {printf("%s\t\t\t - \t SGE\n", yytext); return SGE;}
">>"|"<<"														                                {printf("%s\t\t\t - \t SHIFT\n", yytext); yylval.ch = yytext[0]=='<' ? 'l' : 'r'; return SHIFT;}
"++"|"--"														                                {printf("%s\t\t\t - \t INC_OR_DEC\n", yytext); yylval.ch = yytext[0]=='+' ? 'a' : 's'; return INC_OR_DEC;}
"//"															                                {printf("%s\t\t\t - \t INTDIV\n", yytext); return INTDIV;}
";"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|","|"{"|"}"|"("|")"|"["|"]"|"."|"@"			{printf("%s\t\t\t - \t ITSELF\n", yytext); return yytext[0];}
"*="|"/="|"+="|"%="|">>="|"-="|"<<="|"&="|"^="|"|="|"="											{printf("%s\t\t\t - \t ASGN_OPERATOR\n", yytext); yylval.string = yytext; return ASGN_OPERATOR;}
"true"|"false"																					{yylval.ch = yytext[0]; printf("%s\t\t\t - \t BOOL_CONST\n", yytext); return BOOL_CONST;}
[0-9]+																							{yylval.num = atoi(yytext); printf("%s\t\t\t - \t INTEGER\n", yytext); return INTEGER;}
[0-9]+"."[0-9]+																					{yylval.decimal = atof(yytext); printf("%s\t\t\t - \t FLOAT", yytext); return FLOAT;}
\'([^'\\]|['"?\\abfnrtv]|{UCN})+\'																{yylval.ch = yytext[1]; printf("%s\t\t\t - \t CHAR\n", yytext); return CHAR;}
L?\"([^"\\]|\\['"?\\abfnrtv]|{UCN})*\"															{yylval.string = yytext; printf("%s\t\t\t - \t STRING\n", yytext); return STRING;}																					
([_a-zA-Z]|{UCN})([_a-zA-Z0-9]|{UCN})*			 												{yylval.string = yytext; printf("%s\t\t\t - \t IDENTIFIER\n", yytext); return IDENTIFIER;}

"#"(\\.|[^\n])*[\n]																				{;}
[#][*]([^*]|[*]*[^*/])*[*]+[#]                                          						{;}
[ \t\n]                                          						                        {;}

<INCLFILE>[ \t]*                            {;}    
<INCLFILE>[^ \t\n]+                         {newfile(yytext);}
<<EOF>>                         {
                                    if(--include_stack_ptr) { 
                                        yyterminate();
                                    }
                                    else{
                                        printf("++++++++++++++++++++Did This!++++++++++++++++++++\n");
                                        yy_delete_buffer(YY_CURRENT_BUFFER);
                                        yy_switch_to_buffer(include_stack[include_stack_ptr]);
                                    }
                                    
                                }

.                                                                                               { fprintf(stderr, "%s:%d: Mystery character '%s'\n", curfilename, yylineno, yytext); }
%%

char *strrev(char *str)
{
      char *p1, *p2;

      if (! str || ! *str)
            return str;
      for (p1 = str, p2 = str + strlen(str) - 1; p2 > p1; ++p1, --p2)
      {
            *p1 ^= *p2;
            *p2 ^= *p1;
            *p1 ^= *p2;
      }
      return str;
}

void newfile(char* fn){
    char* filename = strdup(fname);
    strrev(filename);
    filename = strstr(filename, "/");
    strrev(filename);
    strcat(filename, fn);
    printf("Parsed File - %s\n", filename);
    include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;
    printf("++++++++++++++++++++Did That!++++++++++++++++++++\n");
    yyin = fopen(filename, "r" );
    if (!yyin) printf("ERROr!\n");
    yypush_buffer_state(yy_create_buffer(yyin, YY_BUF_SIZE ));
    BEGIN(INITIAL);
}

int yywrap() {
    return 1;
}