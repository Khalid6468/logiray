%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    
    
    
    #include "astnodes.h"

    CompStmtNode *programBlock;
    int yylex();
    int status = 1;
    FILE* yyin;
    char* fname;

    void yyerror();

    
%}

%union {
    Node *node;
    CompStmtNode *block;
    ExprNode *expr;
    StmtNode *stmt;
    IdenNode *iden;
    std::vector<VarDeclNode*> *varvec;
    std::vector<ExprNode*> *exprvec;

    int num;
    bool temp;
    float decimal;
    char ch;
    char* string;
}

%start PROGRAM
%token SWITCH CASE DEFAULT IF ELSE FOR DO WHILE CONTINUE BREAK STRUCT RETURN SIZEOF PROLOGIF
%token <num> AND OR ISEQUAL ISNOTEQUAL LE GE SLE SGE IMPORT INTDIV
%token <ch> SHIFT INC_OR_DEC CHAR 
%token <string> TYPE ASGN_OPERATOR IDENTIFIER STRING FILENAME
%token <num> INTEGER
%token <decimal> FLOAT
%token <temp> BOOL_CONST

%type <iden> TOKIDENTIFIER DECL_SPECIFIER 

%type <expr> CONSTANT EXPRESSION INITIALIZER PARAM_DECL ASGN_EXPR COMPARISION_EXPR SHIFT_EXPR ADDITION_EXPR MULTIP_EXPR CAST_EXPR LOGIC_AND_EXPR 
%type <expr> INCLU_OR_EXPR LOGIC_OR_EXPR EQUALITY_CHECK 

%type <block> PROGRAM TRANSLATION_UNIT COMPOUND_STMT COMPSTMTS DECLARATION STATEMENT

%type <varvec> DECLARATION_LIST
%type <exprvec> PARAM_LIST ARG_EXPR_LIST TOKIDENTIFIER_LIST DECLARATOR
%type <num> ADD SUB MULTIP DIV MOD
%type <stmt> JUMP_STMT LABELLED_STMT EXPRESSION_STMT IFELSE_STMT LOOP_STMT

%type <node> EXTERNAL_DECL PROLOG_DEF PROLOG_EXPR_LIST FACT PROLOG_EXPR PROLOG_LIST FUNCTION TYPE_SPEC STRUCT_SPECIFIER STRUCT_DECLARATION_LIST INIT_DECL_LIST INIT_DECLARATOR
%type <node> STRUCT_DECLARATION STRUCT_DECLARATOR_LIST STRUCT_DECLARATOR INITIALIZER_LIST FOREXPRESSION COND_EXPR
%type <node> CONSTANT_EXPR XOR_EXPR AND_EXPR UNARY_EXPR UNARY_OPERATOR POSTFIX_EXPR PRIMARY_EXPR

%left '+' '-'
%left '*' '/'
%nonassoc "then"
%nonassoc ELSE

%%
PROGRAM                 :   TRANSLATION_UNIT {programBlock = $1;};

TRANSLATION_UNIT        :   EXTERNAL_DECL {$$ = new CompStmtNode(); $$->statements.push_back($<stmt>1);}
                        |   TRANSLATION_UNIT EXTERNAL_DECL {$1->statements.push_back($<stmt>2);};

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
                        |   DECLARATOR '(' TOKIDENTIFIER_LIST ')'
                        |   DECLARATOR '(' PROLOG_LIST ')'
                        |   '!' PROLOG_EXPR;

PROLOG_LIST             :   '[' ']'
                        |   '[' CHAR '|' TOKIDENTIFIER ']';

FUNCTION                :   DECL_SPECIFIER DECLARATOR DECLARATION_LIST COMPOUND_STMT {$$ = new FuncDeclNode(*$1, *$2, *$3, *$4); delete $3;}
                        |   DECLARATOR DECLARATION_LIST COMPOUND_STMT {$$ = new FuncDeclNode2(*$1, *$2, *$3); delete $2;}
                        |   DECL_SPECIFIER DECLARATOR COMPOUND_STMT
                        |   DECLARATOR COMPOUND_STMT;

DECLARATION             :   DECL_SPECIFIER INIT_DECL_LIST ';'
                        |   DECL_SPECIFIER ';';

DECLARATION_LIST        :   DECLARATION
                        |   DECLARATION_LIST DECLARATION;

DECL_SPECIFIER          :   TYPE_SPEC DECL_SPECIFIER
                        |   TYPE_SPEC;

TYPE_SPEC               :   TYPE
                        |   STRUCT_SPECIFIER;

STRUCT_SPECIFIER        :   STRUCT TOKIDENTIFIER '{' STRUCT_DECLARATION_LIST '}'
                        |   STRUCT '{' STRUCT_DECLARATION_LIST '}'
                        |   STRUCT TOKIDENTIFIER;

STRUCT_DECLARATION_LIST :   STRUCT_DECLARATION
                        |   STRUCT_DECLARATION_LIST STRUCT_DECLARATION;

INIT_DECL_LIST          :   INIT_DECLARATOR
                        |   INIT_DECL_LIST ',' INIT_DECLARATOR;

INIT_DECLARATOR         :   DECLARATOR
                        |   DECLARATOR ASGN_OPERATOR INITIALIZER {$$ = new AssigNode(*$<iden>1, *$3);};

STRUCT_DECLARATION      :   TYPE_SPEC STRUCT_DECLARATOR_LIST ';' ;

STRUCT_DECLARATOR_LIST  :   STRUCT_DECLARATOR
                        |   STRUCT_DECLARATOR_LIST ',' STRUCT_DECLARATOR;

STRUCT_DECLARATOR       :   DECLARATOR
                        |   DECLARATOR ':' CONSTANT_EXPR
                        |   ':' CONSTANT_EXPR;

DECLARATOR              :   TOKIDENTIFIER {$$ = new ExprList(); $$->push_back($1);}
                        |   '(' DECLARATOR ')' 
                        |   DECLARATOR '[' CONSTANT_EXPR ']'
                        |   DECLARATOR '[' ']' 
                        |   DECLARATOR '(' PARAM_LIST ')' 
                        |   DECLARATOR '(' TOKIDENTIFIER_LIST ')' {$$ = new ExprList(); $$->push_back(new MethodCallNode(*$1, *$3)); delete $3;}
                        |   DECLARATOR '(' ')';

PARAM_LIST              :   PARAM_DECL {$$ = new ExprList(); $$->push_back($1);}
                        |   PARAM_LIST ',' PARAM_DECL {$1->push_back($3);};

PARAM_DECL              :   DECL_SPECIFIER DECLARATOR;

TOKIDENTIFIER_LIST      :   TOKIDENTIFIER {$$ = new ExprList(); $$->push_back($1);}
                        |   TOKIDENTIFIER_LIST ',' TOKIDENTIFIER {$1->push_back($3);};

TOKIDENTIFIER           :   IDENTIFIER {$$ = new IdenNode($1); delete $1;};

INITIALIZER             :   ASGN_EXPR
                        |   '{' INITIALIZER_LIST '}' ;

INITIALIZER_LIST        :   INITIALIZER
                        |   INITIALIZER_LIST ',' INITIALIZER;

STATEMENT               :   LABELLED_STMT {$$ = new CompStmtNode(); $$->statements.push_back($<stmt>1);}
                        |   EXPRESSION_STMT {$$ = new CompStmtNode(); $$->statements.push_back($<stmt>1);}
                        |   COMPOUND_STMT {$$ = new CompStmtNode(); $$->statements.push_back($<stmt>1);}
                        |   IFELSE_STMT {$$ = new CompStmtNode(); $$->statements.push_back($<stmt>1);}
                        |   LOOP_STMT {$$ = new CompStmtNode(); $$->statements.push_back($<stmt>1);}
                        |   JUMP_STMT {$$ = new CompStmtNode(); $$->statements.push_back($<stmt>1);} ;

LABELLED_STMT           :   TOKIDENTIFIER ':' STATEMENT
                        |   CASE CONSTANT_EXPR ':' STATEMENT
                        |   DEFAULT ':' STATEMENT;

EXPRESSION_STMT         :   EXPRESSION ';' { $$ = new ExprStmtNode(*$1); }
                        |   ';' ;

COMPOUND_STMT           :   '{' COMPSTMTS '}' {$$ = $2;}
                        |   '{' '}';

COMPSTMTS               :   DECLARATION {$$ = $1;}
                        |   STATEMENT {$$ = $1;}
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
                        |   RETURN EXPRESSION ';' {$$ = new ReturStmtNode(*$2);}
                        |   RETURN ';' ;

FOREXPRESSION           :   TYPE EXPRESSION 
                        |   EXPRESSION;

EXPRESSION              :   ASGN_EXPR
                        |   EXPRESSION ',' ASGN_EXPR
                        ;

ASGN_EXPR               :   COND_EXPR
                        |   UNARY_EXPR ASGN_OPERATOR ASGN_EXPR {$$ = new AssigNode(*$<iden>1, *$3);};

COND_EXPR               :   LOGIC_OR_EXPR
                        |   LOGIC_OR_EXPR '?' EXPRESSION ':' COND_EXPR;

CONSTANT_EXPR           :   COND_EXPR;

LOGIC_OR_EXPR           :   LOGIC_AND_EXPR
                        |   LOGIC_OR_EXPR OR LOGIC_AND_EXPR {$$ = new BinOpNode(*$1, $2, *$3);};

LOGIC_AND_EXPR          :   INCLU_OR_EXPR
                        |   LOGIC_AND_EXPR AND INCLU_OR_EXPR {$$ = new BinOpNode(*$1, $2, *$3);};

INCLU_OR_EXPR           :   XOR_EXPR
                        |   INCLU_OR_EXPR '|' XOR_EXPR;

XOR_EXPR                :   AND_EXPR
                        |   XOR_EXPR '^' AND_EXPR;

AND_EXPR                :   EQUALITY_CHECK
                        |   AND_EXPR '&' EQUALITY_CHECK;

EQUALITY_CHECK          :   COMPARISION_EXPR
                        |   EQUALITY_CHECK ISEQUAL COMPARISION_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   EQUALITY_CHECK ISNOTEQUAL COMPARISION_EXPR {$$ = new BinOpNode(*$1, $2, *$3);};

COMPARISION_EXPR        :   SHIFT_EXPR
                        |   COMPARISION_EXPR LE SHIFT_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   COMPARISION_EXPR GE SHIFT_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   COMPARISION_EXPR SLE SHIFT_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   COMPARISION_EXPR SGE SHIFT_EXPR {$$ = new BinOpNode(*$1, $2, *$3);} ;

SHIFT_EXPR              :   ADDITION_EXPR
                        |   SHIFT_EXPR SHIFT ADDITION_EXPR {$$ = new BinOpNode(*$1, $2, *$3);} ;

ADDITION_EXPR           :   MULTIP_EXPR
                        |   ADDITION_EXPR ADD MULTIP_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   ADDITION_EXPR SUB MULTIP_EXPR {$$ = new BinOpNode(*$1, $2, *$3);} ;

MULTIP_EXPR             :   CAST_EXPR
                        |   MULTIP_EXPR MULTIP CAST_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   MULTIP_EXPR DIV CAST_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   MULTIP_EXPR INTDIV CAST_EXPR {$$ = new BinOpNode(*$1, $2, *$3);}
                        |   MULTIP_EXPR MOD CAST_EXPR {$$ = new BinOpNode(*$1, $2, *$3);} ;

MULTIP                  : '*';

DIV                     : '/';

MOD                     : '%';

ADD                     : '+';

SUB                     : '-';

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
                        |   POSTFIX_EXPR '.' TOKIDENTIFIER
                        |   POSTFIX_EXPR INC_OR_DEC;

PRIMARY_EXPR            :   TOKIDENTIFIER 
                        |   CONSTANT
                        |   STRING 
                        |   '(' EXPRESSION ')'{$$ = $2};

ARG_EXPR_LIST           :   ASGN_EXPR  {$$ = new ExprList(); $$->push_back($1);}     
                        |   ARG_EXPR_LIST ',' ASGN_EXPR {$1->push_back($3);};

CONSTANT                :   INTEGER       {$$ = new IntNode($1);}
                        |   CHAR          {$$ = new CharNode($1);}
                        |   FLOAT         {$$ = new DoubleNode($1);}
                        |   BOOL_CONST    {$$ = new BoolNode($1);};


%%

int main(int argc, char** argv) {

    for (int i = 1; i < argc; ++i) {
        fname = argv[i];
        yyin = fopen(fname, "r");

        yyparse(); 

        fclose(yyin);
    }

    if (status==1)
        printf("\n******Parsing Successful!******");
    
}

void yyerror () {
    extern int yylineno;
    
    std::cout << "Parsing failed at Line " << yylineno << "\nSyntax Error!\n";
    status = 0;
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

