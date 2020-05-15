%{
#include "y.tab.h"
#include "strings.h"
#include <math.h>
%}
%option noyywrap
%option yylineno
%%
[ \t\n\r] ;

[,\[\]=] return *yytext;

    /* Match float value infinity with optional plus or minus sign */
    /* i.e. inf; +inf; -inf */
[+-]?inf {
    yylval.vdouble = (yytext[0] == '-') ? -INFINITY : INFINITY;
    return tfloat;
}

    /* Match float value "not a number" */
nan {
    yylval.vdouble = NAN;
    return tfloat;
}

true return VTRUE;

false return VFALSE;

    /* Matches a bare key (not dotted nor quoted) */
    /* i.e. bare_key; bare-key; 1234*/
[A-Za-z0-9_-]+ {
        yylval.vstr = strdup(yytext);
        return tkey_bare;
    }

    /* Match basic string inside quotes " */
\"[^"]+\" {
        yytext[yyleng-1] = 0;
        yylval.vstr = strdup(yytext+1);
        return tstring_basic;
    }

    /* Match a simple integer */
    /* i.e. +99; 42; 0; -17 */
[-+]?[0-9]+ {
        yylval.vint = atoi(yytext);
        return tinteger;
    }

    /* Match an integer separated by underscores */
    /* i.e. 5_349_221; 1_2_3_4_5 */
[-+]?[0-9]+(\_[0-9]+)+ {
        strrmc(yytext, '_');
        yylval.vint = atoi(yytext);
        return tinteger;
    }

    /* Match floating point value with fractional (and/or) exponent part */
    /* i.e. +3.1415; 5e+22; 6.626e-34 */
[-+]?[0-9]+(\.[0-9]+)+([eE][+-]?[0-9]+)? {
        //yylval.num = atof(yytext);
        //yyval.type = TOML_FLOAT_TYPE_NUM;
        return tfloat;
    }


. return ERRO;
