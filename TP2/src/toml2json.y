%{
#include <stdio.h>
extern int yylex();
extern int yylineno;
int yyerror();
%}

%union{
    int vint;
    double vdouble;
    char* vstr;
}

%token ERRO VTRUE VFALSE
%token tinteger tstring_basic tfloat;
%token tkey_bare
%token ttable_basic
%type <vint> tinteger;
%type <vstr> tkey_bare ttable_basic tstring_basic;
%type <vdouble> tfloat;

%%

Parser 
    : KeyValuePair
    ;

KeyValuePair
    : Key '=' Value
    ;

Key
    : tkey_bare
    | tstring_basic
    ;

Value
    : String
    | Integer
    | Float
    | Boolean
    | Array
    ;

String
    : tstring_basic
    ;

Integer
    : tinteger
    ;

Float
    : tfloat {printf("%f\n", $1);}
    ;

Boolean
    : VTRUE
    | VFALSE
    ;

Array
    : '[' ']'
    | '[' Values ']'
    ;

Values
    : Values ',' Value
    | Value
    ;

%%
int main(){
    yyparse();
    return 0;
}

int yyerror(){
    printf("Erro sintatico na linha %d.", yylineno);
    return 0;
}
