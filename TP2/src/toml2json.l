%{
#include "tomlValue.h"
#include "y.tab.h"
#include "strings.h"
#include <math.h>
%}
%option noyywrap
%option noinput
%option nounput
%option yylineno
%%
[ \t\r] ;

[,\[\]=] return *yytext;

\n+ { return NEWLINES; };

    /* Commented Line */
#.*\n ;

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


    /* Match a simple integer */
    /* i.e. +99; 42; 0; -17 */
[-+]?[0-9]+ {
        yylval.vint = atoi(yytext);
        return tinteger;
    } 

    /* Matches a bare key (not dotted nor quoted) */
    /* i.e. bare_key; bare-key; 1234*/
[A-Za-z0-9_-]+ {
        yylval.vstr = strdup(yytext);
        return tkey_bare;
    }

    /* Matches a dotted key */
    /* i.e. dotted.key */
[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+)+ {
        yylval.vstr = strdup(yytext);
        return tkey_dotted;
    }

    /* Match floating point value with fractional (and/or) exponent part */
    /* i.e. +3.1415; 5e+22; 6.626e-34 */
[-+]?[0-9]+(\.[0-9]+)+([eE][+-]?[0-9]+)? {
        yylval.vdouble = atof(yytext);
        return tfloat;
    }

    /* Match basic string inside quotes " */
\"[^"]+\" {
        yytext[yyleng-1] = 0;
        yylval.vstr = strdup(yytext+1);
        return tstring_basic;
    }

    /* Match an integer separated by underscores */
    /* i.e. 5_349_221; 1_2_3_4_5 */
[-+]?[0-9]+(\_[0-9]+)+ {
        strrmc(yytext, '_');
        yylval.vint = atoi(yytext);
        return tinteger;
    }


. return ERRO;
