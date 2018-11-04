%{
#include <stdio.h>
#include <string.h>
#include "sunit.tab.h"
int  yywrap(void) { return 1; }
#define SIZ_BUF		(256)
extern char buf[SIZ_BUF];
extern int yylex(void);
%}
%%
"+"				{ return ADD; }
"-"				{ return SUB; }
"int"			{ return TYPE; }
"void"			{ return TYPE; }
"return"		{ return RETURN; }
"\n"			{ return CR; }
";"				{ return EOS; }
","				{ return COMMA; }
"="				{ return EQ; }
"!="			{ return EQ; }
"&&"			{ return AND; }
"||"			{ return OR; }
""				{ return NONE; }
"{"				{ return L_BRA; }
"}"				{ return R_BRA; }
"if"			{ return IF; }
"else"			{ return IF; }

\".+\"			{ return RITERAL; }
[\ ]+			{ return SP; }
[a-zA-Z_]+		{
					strcpy(yylval.lval_str,yytext);
					return SYMBOL;
				}
[\(\)]			{ return MARU_BRA; }
[1-9][0-9]* 	{
					int temp;
					temp = atoi(yytext);
					yylval.lval_num = temp;
					return NUMBER;
				}
%%
