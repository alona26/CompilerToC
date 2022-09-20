%{
#include "yacc.tab.h"
#include "string.h"
int count = 1; // count the %d
int count_comma = 0 ; // count the number of comma
int dot_prod_flag = 0; // 
int ops_flag = 0; // 
// int flag_arr = 0; //
int flag_squre = 0;




%}
%%
        
"//".+                        {;}
[ |\t|\n]+                  {;}
"-"?(0|[1-9]([0-9])*)              {sscanf(yytext, "%s", yylval.opr); return NUM;}
"@"                         {dot_prod_flag = 1;sscanf(yytext, "%s", yylval.opr); return DOT_PROD;}
"("                         {return OPEN;}
")"                         {return CLOSE;}
"["                         {flag_squre = 1; ops_flag = 1; return OPEN_SQUER;}
"]"                         {return CLOSE_SQUER;}
"="                         {count_comma = 0 ; return ASSIGN;}
"+"|"-"                     {sscanf(yytext, "%s", yylval.opr); return PLUS_AND_MINUS;};
"/"|"*"                     {sscanf(yytext, "%s", yylval.opr); return MULTI_DEV;};
">"|"<"|">="|"<="|"!="|"==" {sscanf(yytext, "%s", yylval.relOp); return LOGICAL;}
"int"                       {sscanf(yytext, "%s", yylval.expression); return INT;}
"arr"                       {sscanf(yytext, "%s", yylval.expression); return ARR;}
[B|b]"egin"                 {return begin_t;}
"end"                       {return end_t;}
"if"                        {sscanf(yytext, "%s", yylval.expression); return if_t;}
"then"                      {return then_t;}
"while"                     {sscanf(yytext, "%s", yylval.expression); return while_t;}
"do"                        {return do_t;}
";"                         {count = 1; return SEMICOL;}
","                         {return COMMA_KEY;}
"print"                     {return PRINT;}
[a-zA-Z|_][a-zA-Z0-9_]*:  {sscanf(yytext, "%[a-zA-Z_][a-zA-Z0-9_]*", yylval.expression); return INDEXING;}
[a-zA-Z|_][a-zA-Z0-9_]*   {sscanf(yytext, "%s", yylval.expression); return IDN;}												
.                           {fprintf(yyout,"<UNKNOWN, %s>\n", yytext);}
%%
  
/*** Code Section prints the number of
capital letter present in the given input***/
int yywrap(void)
{
    return 1;
}