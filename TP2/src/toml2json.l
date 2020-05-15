%{
#include "y.tab.h"
#include "strings.h"
#include <math.h>
%}
%option noyywrap
%option yylineno
%%
[ \t\n\r] ;

[,\[\]] return *yytext;

\"[^"]+\" {
        yytext[yyleng-1] = 0;
        yylval.vstr = strdup(yytext+1);
        return tstring;
    }

[-+]?[0-9]+ {
        yylval.vint = atoi(yytext);
        return tinteger;
    }

[-+]?[0-9]+(\_[0-9]+)+ {
        strrmc(yytext, '_');
        yylval.vint = atoi(yytext);
        return tinteger;
    }

[-+]?[0-9]+(\.[0-9]+)+([eE][+-]?[0-9]+)? {
        //yylval.num = atof(yytext);
        //yyval.type = TOML_FLOAT_TYPE_NUM;
        return tfloat;
    }

\+?inf {
    yylval.vdouble = INFINITY;
    return tfloat;
}

-inf {
    yylval.vdouble = -INFINITY;
    return tfloat;
}

nan {
    yylval.vdouble = NAN;
    return tfloat;
}

true return VTRUE;

false return VFALSE;

. return ERRO;
