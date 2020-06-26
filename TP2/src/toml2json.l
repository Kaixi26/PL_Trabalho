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

keychar     [A-Za-z0-9_-]
keybase     {keychar}+(\.{keychar}+)*
keymquot    ({keybase}|(\"{keybase}\")|(\'{keybase}\'))
keyfull     {keymquot}(\.{keymquot})*

%%
[ \t\r] ;

[,\[\]=\n] return *yytext;

    /* Commented Line */
#.*/(\n) ;

    /* Match float value infinity with optional plus or minus sign */
    /* i.e. inf; +inf; -inf */
[+-]?inf {
    yylval.vdouble = (yytext[0] == '-') ? -INFINITY : INFINITY;
    return tfloat;
}

    /* Match float value "not a number" */
[+-]?nan {
    yylval.vdouble = NAN;
    return tfloat;
}

true return VTRUE;

false return VFALSE;


    /* Match a simple integer */
    /* i.e. +99; 42; 0; -17 */
[-+]?[0-9]+ {
        yylval.vstr = strdup(yytext);
        return tinteger;
    } 

    /* Match an integer separated by underscores */
    /* i.e. 5_349_221; 1_2_3_4_5 */
[-+]?[0-9]+(\_[0-9]+)+ {
        yylval.vstr = strdup(yytext);
        return tinteger_underscored;
    }

    /* Offset Date-Time defined in RFC 3339 */
    /* 1979-05-27T07:32:00Z ; 1979-05-27T00:32:00-07:00 */
    /* 1979-05-27T00:32:00.999999-07:00 ; 1979-05-27 07:32:00Z */
[0-9]{4}(-[0-9]{2}){2}(T|\ )[0-9]{2}(:[0-9]{2}){2}(Z|((\.[0-9]{6})?-[0-9]{2}:[0-9]{2})) {
    yylval.vstr = strdup(yytext);
    return date;
}

    /* Local Date-Time defined in RFC 3339 */
    /* 1979-05-27T07:32:00 */
    /* 1979-05-27T00:32:00.999999 */
[0-9]{4}(-[0-9]{2}){2}(T|\ )[0-9]{2}(:[0-9]{2}){2}(Z|((\.[0-9]{6})?)) {
    yylval.vstr = strdup(yytext);
    return date;
}

    /* Local Date defined in RFC 3339 */
    /* 1979-05-27 */
[0-9]{4}(-[0-9]{2}){2} {
    yylval.vstr = strdup(yytext);
    return date;
}

    /* Local Time defined in RFC 3339 */
    /* 07:32:00 */
    /* 00:32:00.999999 */
[0-9]{2}(:[0-9]{2}){2}(\.[0-9]{6})? {
    yylval.vstr = strdup(yytext);
    return date;
} 

    /* Match floating point value with fractional (and/or) exponent part */
    /* i.e. +3.1415; 5e+22; 6.626e-34 */
[-+]?[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)? {
        yylval.vdouble = atof(yytext);
        return tfloat;
    }

    /* Match basic string inside quotes " */
\"[^"]+\" {
        yytext[yyleng-1] = 0;
        yylval.vstr = strdup(yytext+1);
        return tstring_basic;
    }

    /* Match basic string inside quotes ' */
\'[^']+\' {
        yytext[yyleng-1] = 0;
        yylval.vstr = strdup(yytext+1);
        return tstring_basic;
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

    /* Matches dotted keys, bare mixed with quotted */
    /* i.e. site."google.com" */
{keymquot}(\.{keymquot})* {
        yylval.vstr = strdup(yytext);
        return tkey_dotted;
    }

. return ERRO;
