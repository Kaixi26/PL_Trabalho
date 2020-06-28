%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include "tomlValue.h"
#include "valueTree.h"
extern int yylex();
extern int yylineno;
extern void strrmc(char*, char);
int yyerror();

t_toml_keyvalues* parsedKeyValues;

%}

%union{
    int vint;
    double vdouble;
    char* vstr;
    t_tomlv vtoml;
    t_toml_keyvalue* vkp;
    t_toml_keyvalues* vkps;
}

%token ERRO VTRUE VFALSE
%token <vstr> tinteger tinteger_underscored;
%token <vdouble> tfloat;
%token <vstr> tkey_bare tkey_dotted tstring_basic date;
%type <vstr> Key
%type <vtoml> String Integer Float Boolean Array Value Values
%type <vkp> KeyValuePair
%type <vkps> KeyValuePairs Table Tables
    
%%

Parser 
    : MaybeNewlines Tables { parsedKeyValues = $2; }
    | MaybeNewlines KeyValuePairs { parsedKeyValues = $2; }
    | MaybeNewlines KeyValuePairs Tables { parsedKeyValues = t_toml_keyvalues_merge($2, $3); }
    | MaybeNewlines { parsedKeyValues = t_toml_keyvalues_init(); }
    ;

Tables
    : Tables Table { $$ = t_toml_keyvalues_merge($1, $2); }
    | Table { $$ = $1; }
    ;

Table
    : '[' Key ']' Newlines KeyValuePairs { $$ = $5; t_toml_keyvalues_prepend($$, $2); free($2); }
    | '[' Key ']' Newlines { $$ = t_toml_keyvalues_init(); free($2); }
    ;

KeyValuePairs
    : KeyValuePairs KeyValuePair Newlines { $$ = $1; t_toml_keyvalues_insert($$, $2); }
    | KeyValuePair Newlines { $$ = t_toml_keyvalues_init(); t_toml_keyvalues_insert($$, $1); }
    ;

KeyValuePair
    : Key '=' Value { $$ = t_toml_keyvalue_init($1, $3); }
    ;

Key
    : tkey_bare     { $$ = $1; }
    | tkey_dotted   { $$ = $1; }
    | tstring_basic { $$ = calloc(strlen($1), sizeof(char)); sprintf($$, "\"%s\"", $1); free($1); }
    | tinteger      { $$ = $1; }
    | tinteger_underscored { $$ = $1; }
    ;

Value
    : String    { $$ = $1; }
    | Integer   { $$ = $1; }
    | Float     { $$ = $1; }
    | Boolean   { $$ = $1; }
    | Array     { $$ = $1; }
    ;

String
    : tstring_basic { $$ = t_tomlv_fromStr($1); }
    | date {$$ = t_tomlv_fromStr($1); }
    ;

Integer
    : tinteger { $$ = t_tomlv_fromInt(atoi($1)); free($1); }
    | tinteger_underscored {  strrmc($1, '_'); $$ = t_tomlv_fromInt(atoi($1)); free($1); }
    ;

Float
    : tfloat { $$ = t_tomlv_fromDouble($1); }
    ;

Boolean
    : VTRUE { $$ = t_tomlv_fromBool(1); }
    | VFALSE { $$ = t_tomlv_fromBool(0); }
    ;

Array
    : '[' MaybeNewlines ']' { $$ = t_tomlv_fromArr(t_toml_arr_init()); }
    | '[' MaybeNewlines Values ']' { $$ = $3; }
    | '[' MaybeNewlines Values ',' MaybeNewlines ']' { $$ = $3; }
    ;

Values
    : Values ',' MaybeNewlines Value MaybeNewlines {$$ = $1; t_toml_arr_append($$.val.varr, $4); }
    | Value MaybeNewlines { $$ = t_tomlv_fromArr(t_toml_arr_init()); t_toml_arr_append($$.val.varr, $1); }
    ;

MaybeNewlines
    : Newlines
    |
    ;

Newlines
    : Newlines '\n'
    | '\n'
    ;


%%

valueTree* vtree;
int main(){
    int err = yyparse();
    if(err) return err;
    vtree = valueTree_fromKeyValues(parsedKeyValues);
    valueTree_print(vtree);
    printf("\n");
    return 0;
}

int yyerror(){
    fprintf(stderr, "Syntax error: Line %d.\n", yylineno);
    return 1;
}
