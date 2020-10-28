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
    extern char* fname;
%}

%%

"void"|"char"|"int"|"float"|"bool"|"string"					   	                                {yylval.string = yytext; printf("%s\t\t - \t TYPE\n", yytext); return TYPE;}	
"switch"														                                {printf("%s\t\t - \t SWITCH\n", yytext); return SWITCH;}
"case"															                                {printf("%s\t\t - \t CASE\n", yytext); return CASE;}	
"default"														                                {printf("%s\t\t - \t DEFAULT\n", yytext); return DEFAULT;}
"if"															                                {printf("%s\t\t - \t IF\n", yytext); return IF;}
"else"															                                {printf("%s\t\t - \t ELSE\n", yytext); return ELSE;}
"for"															                                {printf("%s\t\t - \t FOR\n", yytext); return FOR;}
"do"															                                {printf("%s\t\t - \t DO\n", yytext); return DO;}
"while"															                                {printf("%s\t\t - \t WHILE\n", yytext); return WHILE;}
"continue"														                                {printf("%s\t\t - \t CONTINUE\n", yytext); return CONTINUE;}
"break"															                                {printf("%s\t\t - \t BREAK\n", yytext); return BREAK;}
"struct"													                                    {printf("%s\t\t - \t STRUCT\n", yytext); return STRUCT;}
"return"														                                {printf("%s\t\t - \t RETURN\n", yytext); return RETURN;}
"sizeof"														                                {printf("%s\t\t - \t SIZEOF\n", yytext); return SIZEOF;}
"plif"|":-"															                            {printf("%s\t\t - \t PROLOGIF\n", yytext); return PROLOGIF;}
"||"                                                                                            {printf("%s\t\t - \t OR\n", yytext); return OR;}
"&&"															                                {printf("%s\t\t - \t AND\n", yytext); return AND;}
"=="|"is"														                                {printf("%s\t\t - \t ISEQUAL\n", yytext); return ISEQUAL;}
"!="|"isnot"													                                {printf("%s\t\t - \t ISNOTEQUAL\n", yytext); return ISNOTEQUAL;}
"<="															                                {printf("%s\t\t - \t LE\n", yytext); return LE;}
">="															                                {printf("%s\t\t - \t GE\n", yytext); return GE;}
"<"																                                {printf("%s\t\t - \t SLE\n", yytext); return SLE;}
">"																                                {printf("%s\t\t - \t SGE\n", yytext); return SGE;}
">>"|"<<"														                                {printf("%s\t\t - \t SHIFT\n", yytext); yylval.ch = yytext[0]=='<' ? 'l' : 'r'; return SHIFT;}
"++"|"--"														                                {printf("%s\t\t - \t INC_OR_DEC\n", yytext); yylval.ch = yytext[0]=='+' ? 'a' : 's'; return INC_OR_DEC;}
"//"															                                {printf("%s\t\t - \t INTDIV\n", yytext); return INTDIV;}
";"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|","|"{"|"}"|"("|")"|"["|"]"|"."				{printf("%s\t\t - \t ITSELF\n", yytext); return yytext[0];}
"*="|"/="|"+="|"%="|">>="|"-="|"<<="|"&="|"^="|"|="|"="											{printf("%s\t\t - \t ASGN_OPERATOR\n", yytext); yylval.string = yytext; return ASGN_OPERATOR;}
"true"|"false"																					{yylval.ch = yytext[0]; printf("%s\t\t - \t BOOL_CONST\n", yytext); return BOOL_CONST;}
[0-9]+																							{yylval.num = atoi(yytext); printf("%s\t\t - \t INTEGER\n", yytext); return INTEGER;}
[0-9]+"."[0-9]+																					{yylval.decimal = atof(yytext); printf("%s\t\t - \t FLOAT", yytext); return FLOAT;}
\'([^'\\]|['"?\\abfnrtv]|{UCN})+\'																{yylval.ch = yytext[1]; printf("%s\t\t - \t CHAR\n", yytext); return CHAR;}
L?\"([^"\\]|\\['"?\\abfnrtv]|{UCN})*\"															{yylval.string = yytext; printf("%s\t\t - \t STRING\n", yytext); return STRING;}																					
([_a-zA-Z]|{UCN})([_a-zA-Z0-9]|{UCN})*			 												{yylval.string = yytext; printf("%s\t\t - \t IDENTIFIER\n", yytext); return IDENTIFIER;}
[a-zA-z_.][a-zA-z_0-9./]*                                                                       {yylval.string = yytext; printf("%s\t\t - \t FILENAME\n", yytext); return FILENAME;}

"#"(\\.|[^\n])*[\n]																				{;}
[#][*]([^*]|[*]*[^*/])*[*]+[#]                                          						{;}
[ \t\n]                                          						                        {;}


^import[ \t]+ 	                                                                                { BEGIN IFILE; printf("%s\t\t - \t IMPORT\n", yytext); }
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

int newfile(char* fn){

    strrev(fname);
    fname = strstr(fname, "/");
    strrev(fname);
    strcat(fname, fn);

    FILE* f = fopen(fname, "r");
    struct bufstack* bs = (struct bufstack*)malloc(sizeof(struct bufstack));

    if(!f){
        perror(fname);
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
    curfilename = fname;
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