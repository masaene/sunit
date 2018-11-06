%{
#include <stdio.h>
#include <string.h>
#include "sunit.tab.h"
int  yywrap(void) { return 1; }
#define SIZ_BUF		(256)
#define REG_SP			[\ ]*
extern char buf[SIZ_BUF];
extern int yylex(void);
%}
%%
"+"					{ return ADD; }
"-"					{ return SUB; }
"int"				{	strcpy(yylval.lval_str,yytext);
						return TYPE;
					}
[\ ]*return[\ ]*	{ return RETURN; }
"\n"				{ return CR; }
";"					{ return EOS; }
[\ ]*","[\ ]*		{ return COMMA; }
[\ ]*"="[\ ]*		{ return EQ; }
[\ ]*"!="[\ ]*		{ return NQ; }
[\ ]*"=="[\ ]*		{ return EE; }
[\ ]*"&&"[\ ]*		{ return AND; }
[\ ]*"||"[\ ]*		{ return OR; }
""					{ return NONE; }
[\ ]*"{"[\ ]*		{ return L_BRACE; }
[\ ]*"}"[\ ]*		{ return R_BRACE; }
[\ ]*"("[\ ]*		{ return L_PAREN; }
[\ ]*")"[\ ]*		{ return R_PAREN; }
[\ ]*"if"[\ ]*		{ return IF; }
[\ ]*"else"[\ ]*	{ return ELSE; }

\".+\"				{ return RITERAL; }
[\ ]+				{ return SP; }
[a-zA-Z_]+			{
					strcpy(yylval.lval_str,yytext);
					return SYMBOL;
					}
[1-9][0-9]* 		{
					yylval.lval_num = atoi(yytext);
					return NUMBER;
					}
%%
