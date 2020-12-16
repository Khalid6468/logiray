%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    void yyerror();
    int yylex();
    int status = 1;
    FILE* yyin;
    char* fname;
%}

%union {
    int num;
    float decimal;
    char ch;
    char *string;
}

%start PROGRAM
%token SWITCH CASE DEFAULT IF ELSE FOR DO WHILE CONTINUE BREAK STRUCT RETURN SIZEOF PROLOGIF
%token AND OR ISEQUAL ISNOTEQUAL LE GE SLE SGE IMPORT INTDIV
%token <ch> SHIFT INC_OR_DEC CHAR BOOL_CONST
%token <string> TYPE ASGN_OPERATOR IDENTIFIER STRING FILENAME
%token <num> INTEGER
%token <decimal> FLOAT

%left '+' '-'
%left '*' '/'
%nonassoc "then"
%nonassoc ELSE

%%
PROGRAM                 :   EXTERNAL_DECL
                        |   PROGRAM EXTERNAL_DECL;

EXTERNAL_DECL           :   FUNCTION
                        |   DECLARATION
                        |   FACT
                        |   PROLOG_DEF;

PROLOG_DEF              :   PROLOG_EXPR PROLOGIF PROLOG_EXPR_LIST '.';

PROLOG_EXPR_LIST        :   PROLOG_EXPR
                        |   COND_EXPR
                        |   PROLOG_EXPR_LIST ',' PROLOG_EXPR
                        |   PROLOG_EXPR_LIST ',' COND_EXPR;

FACT                    :   PROLOG_EXPR '.';

PROLOG_EXPR             :   DECLARATOR '(' ')'
                        |   DECLARATOR '(' IDENTIFIER_LIST ')'
                        |   DECLARATOR '(' CONSTANT ')'
                        |   DECLARATOR '(' EXPRESSION ')'
                        |   DECLARATOR '(' PROLOG_LIST ')'
                        |   '!' PROLOG_EXPR;

PROLOG_LIST             :   '[' ']'
                        |   '[' CHAR '|' IDENTIFIER ']';

FUNCTION                :   DECL_SPECIFIER DECLARATOR DECLARATION_LIST COMPOUND_STMT
                        |   DECLARATOR DECLARATION_LIST COMPOUND_STMT
                        |   DECL_SPECIFIER DECLARATOR COMPOUND_STMT
                        |   DECLARATOR COMPOUND_STMT;

DECLARATION             :   DECL_SPECIFIER INIT_DECL_LIST ';'
                        |   DECL_SPECIFIER ';';

DECLARATION_LIST        :   DECLARATION
                        |   DECLARATION_LIST DECLARATION;

DECL_SPECIFIER          :   TYPE_SPEC DECL_SPECIFIER
                        |   TYPE_SPEC;

TYPE_SPEC               :   TYPE
                        |   STRUCT_SPECIFIER

STRUCT_SPECIFIER        :   STRUCT IDENTIFIER '{' STRUCT_DECLARATION_LIST '}'
                        |   STRUCT '{' STRUCT_DECLARATION_LIST '}'
                        |   STRUCT IDENTIFIER;

STRUCT_DECLARATION_LIST :   STRUCT_DECLARATION
                        |   STRUCT_DECLARATION_LIST STRUCT_DECLARATION;

INIT_DECL_LIST          :   INIT_DECLARATOR
                        |   INIT_DECL_LIST ',' INIT_DECLARATOR;

INIT_DECLARATOR         :   DECLARATOR
                        |   DECLARATOR ASGN_OPERATOR INITIALIZER;

STRUCT_DECLARATION      :   TYPE_SPEC STRUCT_DECLARATOR_LIST ';' ;

STRUCT_DECLARATOR_LIST  :   STRUCT_DECLARATOR
                        |   STRUCT_DECLARATOR_LIST ',' STRUCT_DECLARATOR;

STRUCT_DECLARATOR       :   DECLARATOR
                        |   DECLARATOR ':' CONSTANT_EXPR
                        |   ':' CONSTANT_EXPR;

DECLARATOR              :   IDENTIFIER
                        |   '(' DECLARATOR ')'
                        |   DECLARATOR '[' CONSTANT_EXPR ']'
                        |   DECLARATOR '[' ']'
                        |   DECLARATOR '(' PARAM_LIST ')'
                        |   DECLARATOR '(' IDENTIFIER_LIST ')'
                        |   DECLARATOR '(' ')';

PARAM_LIST              :   PARAM_DECL
                        |   PARAM_LIST ',' PARAM_DECL;

PARAM_DECL              :   DECL_SPECIFIER DECLARATOR;

IDENTIFIER_LIST         :   IDENTIFIER
                        |   IDENTIFIER_LIST ',' IDENTIFIER;

INITIALIZER             :   ASGN_EXPR
                        |   '{' INITIALIZER_LIST '}' ;

INITIALIZER_LIST        :   INITIALIZER
                        |   INITIALIZER_LIST ',' INITIALIZER;

STATEMENT               :   LABELLED_STMT
                        |   EXPRESSION_STMT
                        |   COMPOUND_STMT
                        |   IFELSE_STMT
                        |   LOOP_STMT
                        |   JUMP_STMT;

LABELLED_STMT           :   IDENTIFIER ':' STATEMENT
                        |   CASE CONSTANT_EXPR ':' STATEMENT
                        |   DEFAULT ':' STATEMENT;

EXPRESSION_STMT         :   EXPRESSION ';'
                        |   ';' ;

COMPOUND_STMT           :   '{' COMPSTMTS '}'
                        |   '{' '}';

COMPSTMTS               :   DECLARATION
                        |   STATEMENT
                        |   COMPSTMTS DECLARATION
                        |   COMPSTMTS STATEMENT;

IFELSE_STMT             :   IF '(' EXPRESSION ')' STATEMENT             %prec "then"
                        |   IF '(' EXPRESSION ')' STATEMENT ELSE STATEMENT
                        |   SWITCH '(' EXPRESSION ')' STATEMENT;

LOOP_STMT               :   WHILE '(' EXPRESSION ')' STATEMENT
                        |   DO STATEMENT WHILE '(' EXPRESSION ')' ';'
                        |   FOR '(' FOREXPRESSION ';' EXPRESSION ';' EXPRESSION ')' STATEMENT
                        |   FOR '(' ';' EXPRESSION ';' EXPRESSION ')' STATEMENT
                        |   FOR '(' FOREXPRESSION ';' ';' EXPRESSION ')' STATEMENT
                        |   FOR '(' FOREXPRESSION ';' EXPRESSION ';' ')' STATEMENT
                        |   FOR '(' ';' ';' EXPRESSION ')' STATEMENT
                        |   FOR '(' ';' EXPRESSION ';' ')' STATEMENT
                        |   FOR '(' FOREXPRESSION ';' ';' ')' STATEMENT
                        |   FOR '(' ';' ';' ')' STATEMENT;

JUMP_STMT               :   CONTINUE ';'
                        |   BREAK ';'
                        |   RETURN EXPRESSION ';'
                        |   RETURN ';';

FOREXPRESSION           :   TYPE EXPRESSION
                        |   EXPRESSION;

EXPRESSION              :   ASGN_EXPR
                        |   EXPRESSION ',' ASGN_EXPR
                        ;

ASGN_EXPR               :   COND_EXPR
                        |   UNARY_EXPR ASGN_OPERATOR ASGN_EXPR;

COND_EXPR               :   LOGIC_OR_EXPR
                        |   LOGIC_OR_EXPR '?' EXPRESSION ':' COND_EXPR;

CONSTANT_EXPR           :   COND_EXPR;

LOGIC_OR_EXPR           :   LOGIC_AND_EXPR
                        |   LOGIC_OR_EXPR OR LOGIC_AND_EXPR;

LOGIC_AND_EXPR          :   INCLU_OR_EXPR
                        |   LOGIC_AND_EXPR AND INCLU_OR_EXPR;

INCLU_OR_EXPR           :   XOR_EXPR
                        |   INCLU_OR_EXPR '|' XOR_EXPR;

XOR_EXPR                :   AND_EXPR
                        |   XOR_EXPR '^' AND_EXPR;

AND_EXPR                :   EQUALITY_CHECK
                        |   AND_EXPR '&' EQUALITY_CHECK;

EQUALITY_CHECK          :   COMPARISION_EXPR
                        |   EQUALITY_CHECK ISEQUAL COMPARISION_EXPR
                        |   EQUALITY_CHECK ISNOTEQUAL COMPARISION_EXPR;

COMPARISION_EXPR        :   SHIFT_EXPR
                        |   COMPARISION_EXPR LE SHIFT_EXPR
                        |   COMPARISION_EXPR GE SHIFT_EXPR
                        |   COMPARISION_EXPR SLE SHIFT_EXPR
                        |   COMPARISION_EXPR SGE SHIFT_EXPR;

SHIFT_EXPR              :   ADDITION_EXPR
                        |   SHIFT_EXPR SHIFT ADDITION_EXPR;

ADDITION_EXPR           :   MULTIP_EXPR
                        |   ADDITION_EXPR '+' MULTIP_EXPR
                        |   ADDITION_EXPR '-' MULTIP_EXPR;

MULTIP_EXPR             :   CAST_EXPR
                        |   MULTIP_EXPR '*' CAST_EXPR
                        |   MULTIP_EXPR '/' CAST_EXPR
                        |   MULTIP_EXPR INTDIV CAST_EXPR
                        |   MULTIP_EXPR '%' CAST_EXPR;

CAST_EXPR               :   UNARY_EXPR
                        |   '(' TYPE ')' CAST_EXPR;

UNARY_OPERATOR          :   '+'
                        |   '-'
                        |   '!'
                        |   '~'
                        |   '&';

UNARY_EXPR              :   POSTFIX_EXPR
                        |   INC_OR_DEC UNARY_EXPR
                        |   UNARY_OPERATOR CAST_EXPR
                        |   SIZEOF UNARY_EXPR
                        |   SIZEOF '(' TYPE ')';

POSTFIX_EXPR            :   PRIMARY_EXPR
                        |   POSTFIX_EXPR '[' EXPRESSION ']'
                        |   POSTFIX_EXPR '(' ARG_EXPR_LIST ')'
                        |   POSTFIX_EXPR '(' ')'
                        |   POSTFIX_EXPR '.' IDENTIFIER
                        |   POSTFIX_EXPR INC_OR_DEC;

PRIMARY_EXPR            :   IDENTIFIER
                        |   CONSTANT
                        |   STRING
                        |   '(' EXPRESSION ')';

ARG_EXPR_LIST           :   ASGN_EXPR
                        |   ARG_EXPR_LIST ',' ASGN_EXPR;

CONSTANT                :   INTEGER
                        |   CHAR
                        |   FLOAT
                        |   BOOL_CONST;

%%

int main(int argc, char** argv) {

    for (int i = 1; i < argc; ++i) {
        fname = argv[i];
        yyin = fopen(fname, "r");

        yyparse();  

        fclose(yyin);
    }

    if (status==1)
        printf("\n******Parsing Successful!******\n");
    
}

// void handleImport(char * fname) {
//     strrev(fname);
//     fname = strstr(fname, "/");
//     strrev(fname);
//     strcat(fname, fn);
//     FILE* f = fopen(fname, "r");
//     yyin = fopen($1, "r");
//     yyparse();  
//     fclose(yyin);

// }

void yyerror () {
    extern int yylineno;
	fprintf(stderr, "Parsing failed at Line %d\nSyntax Error!\n",yylineno);
    status = 0;
} 