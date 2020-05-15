%{
#include <stdio.h>
#include "tomlfloat.h"
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
%token tinteger tstring tfloat;
%type <vint> tinteger;
%type <vstr> tstring;
%type <vdouble> tfloat;

%%

Parser 
    : Values
    ;


Value
    : String
    | Integer
    | Float
    | Boolean
    | Array
    ;

String
    : tstring
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
