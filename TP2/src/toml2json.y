%{
#include <stdio.h>
#include "tomlValue.h"
#include "valueTree.h"
extern int yylex();
extern int yylineno;
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

%token ERRO VTRUE VFALSE NEWLINES
%token <vint> tinteger;
%token <vdouble> tfloat;
%token <vstr> tkey_bare tkey_dotted ttable_basic tstring_basic;
%type <vstr> Key
%type <vtoml> String Integer Float Boolean Array Value Values
%type <vkp> KeyValuePair
%type <vkps> KeyValuePairs Table Tables
    
%%

Parser 
    : MaybeNEWLINES Tables { parsedKeyValues = $2; }
    | MaybeNEWLINES KeyValuePairs { parsedKeyValues = $2; }
    | MaybeNEWLINES KeyValuePairs Tables { parsedKeyValues = t_toml_keyvalues_merge($2, $3); }
    | MaybeNEWLINES { parsedKeyValues = t_toml_keyvalues_init(); }
    ;

Tables
    : Tables Table { $$ = t_toml_keyvalues_merge($1, $2); }
    | Table { $$ = $1; }
    ;

Table
    : '[' Key ']' NEWLINES KeyValuePairs { $$ = $5; t_toml_keyvalues_prepend($$, $2); free($2); }
    | '[' Key ']' MaybeNEWLINES { $$ = t_toml_keyvalues_init(); }
    ;

KeyValuePairs
    : KeyValuePairs KeyValuePair MaybeNEWLINES { $$ = $1; t_toml_keyvalues_insert($$, $2); }
    | KeyValuePair MaybeNEWLINES { $$ = t_toml_keyvalues_init(); t_toml_keyvalues_insert($$, $1); }
    ;

KeyValuePair
    : Key '=' Value { $$ = t_toml_keyvalue_init($1, $3); }
    ;

Key
    : tkey_bare     { $$ = $1; }
    | tkey_dotted   { $$ = $1; }
    | tstring_basic { $$ = $1; }
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
    ;

Integer
    : tinteger { $$ = t_tomlv_fromInt($1); }
    ;

Float
    : tfloat { $$ = t_tomlv_fromDouble($1); }
    ;

Boolean
    : VTRUE { $$ = t_tomlv_fromBool(1); }
    | VFALSE { $$ = t_tomlv_fromBool(0); }
    ;

Array
    : '[' MaybeNEWLINES ']' { $$ = t_tomlv_fromArr(t_toml_arr_init()); }
    | '[' MaybeNEWLINES Values ']' { $$ = $3; }
    ;

Values
    : Values ',' MaybeNEWLINES Value MaybeNEWLINES {$$ = $1; t_toml_arr_append($$.val.varr, $4); }
    | Value MaybeNEWLINES { $$ = t_tomlv_fromArr(t_toml_arr_init()); t_toml_arr_append($$.val.varr, $1); }
    ;

MaybeNEWLINES
    : NEWLINES
    |
    ;


%%

int main(){
    int err;
    if(!(err = yyparse())){
        //t_toml_keyvalues_print(parsedKeyValues);
        valueTree* vtree = valueTree_fromKeyValues(parsedKeyValues);
        valueTree_print(vtree);
    }
    return err;
}

int yyerror(){
    fprintf(stderr, "Erro sintatico na linha %d.\n", yylineno);
    return 1;
}
