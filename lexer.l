UCN     (\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})

%option yylineno
%option noyywrap
%x COMMENT
%x IFILE

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "parser.tab.h"
	char* curfilename;
	struct bufstack{
        struct bufstack *prev;
        YY_BUFFER_STATE bs;
        int lineno;
        char* filename;
        FILE* f;
    } *curbs = NULL;
	int newfile(char* fn);
    int popfile(void);
%}

%%

"void"|"char"|"int"|"float"|"bool"|"string"					   	                                {yylval.string = yytext; return TYPE;}	
"switch"														                                {return SWITCH;}
"case"															                                {return CASE;}	
"default"														                                {return DEFAULT;}
"if"															                                {return IF;}
"else"															                                {return ELSE;}
"for"															                                {return FOR;}
"do"															                                {return DO;}
"while"															                                {return WHILE;}
"continue"														                                {return CONTINUE;}
"break"															                                {return BREAK;}
"struct"													                                    {return STRUCT;}
"return"														                                {return RETURN;}
"sizeof"														                                {return SIZEOF;}
"plif"|":-"															                            {return PROLOGIF;}
"||"                                                                                            {return OR;}
"&&"															                                {return AND;}
"=="|"is"														                                {return ISEQUAL;}
"!="|"isnot"													                                {return ISNOTEQUAL;}
"<="															                                {return LE;}
">="															                                {return GE;}
"<"																                                {return SLE;}
">"																                                {return SGE;}
">>"|"<<"														                                {yylval.ch = yytext[0]=='<' ? 'l' : 'r'; return SHIFT;}
"++"|"--"														                                {yylval.ch = yytext[0]=='+' ? 'a' : 's'; return INC_OR_DEC;}
"//"															                                {return INTDIV;}
";"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|","|"{"|"}"|"("|")"|"["|"]"|"."				{return yytext[0];}
"*="|"/="|"+="|"%="|">>="|"-="|"<<="|"&="|"^="|"|="|"="											{yylval.string = yytext; return ASGN_OPERATOR;}
"true"|"false"																					{yylval.ch = yytext[0]; return BOOL_CONST;}
[0-9]+																							{yylval.num = atoi(yytext); return INTEGER;}
[0-9]+"."[0-9]+																					{yylval.decimal = atof(yytext); return FLOAT;}
\'([^'\\]|['"?\\abfnrtv]|{UCN})+\'																{yylval.ch = yytext[1]; return CHAR;}
L?\"([^"\\]|\\['"?\\abfnrtv]|{UCN})*\"															{yylval.string = yytext; return STRING;}																					
([_a-zA-Z]|{UCN})([_a-zA-Z0-9]|{UCN})*			 												{yylval.string = yytext; return IDENTIFIER;}


"#*"                                                                                            {BEGIN(COMMENT);}
<COMMENT>"*#"                                                                                   {BEGIN(INITIAL);}
<COMMENT>([^*]|\n)+|.
<COMMENT><<EOF>>                                                                                {printf("%s:%d: Unterminated comment\n", curfilename, yylineno); return 0;}
"#".*\n
[ \t\n]

^import[ \t]+ 	                                                                                { BEGIN IFILE; }
<IFILE>[^\n]+ 	                                                                                {
                                                                                                    { 
                                                                                                        int c;
                                                                                                        while((c = input()) && c != '\n') ;
                                                                                                        
                                                                                                    }
                                                                                                    newfile(strdup(yytext));
                                                                                                    BEGIN INITIAL;
                                                                                                }

<<EOF>>                                                                                         { if(!popfile()) yyterminate(); }

.                                                                                               { fprintf(stderr, "%s:%d: Mystery character '%s'\n", curfilename, yylineno, yytext); }
%%

int newfile(char* fn){
    FILE* f = fopen(fn, "r");
    struct bufstack* bs = (struct bufstack*)malloc(sizeof(struct bufstack));

    if(!f){
        perror(fn);
        return 0;
    }

    if(!bs){
        perror("malloc");
        exit(1);
    }

    if(curbs)
        curbs->lineno = yylineno;

    bs->prev = curbs;
    bs->bs = yy_create_buffer(f, YY_BUF_SIZE);
    bs->f = f;
    bs->filename = fn;
    yy_switch_to_buffer(bs->bs);
    curbs = bs;
    yylineno = 1;
    curfilename = fn;
    return 1;
}

int popfile(void){
    struct bufstack* bs = curbs;
    struct bufstack* prevbs;

    if(!bs)
        return 0;
    
    fclose(bs->f);
    yy_delete_buffer(bs->bs);

    prevbs = bs->prev;
    free(bs);

    if(!prevbs)
        return 0;
    
    yy_switch_to_buffer(prevbs->bs);
    curbs = prevbs;
    yylineno = curbs->lineno;
    curfilename = curbs->filename;
    return 1;
}