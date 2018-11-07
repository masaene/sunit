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
[\ \t]*"+"[\ \t]*		{	return ADD; }
[\ \t]*"-"[\ \t]*		{	return SUB; }
[\ \t]*"int"[\ \t]+		{	strcpy(yylval.lval_str,yytext);
							return TYPE;
						}
[\ \t]*return[\ \t]+	{	return RETURN; }
"\n"					{	return CR; }
[\ \t]*";"[\ \t]*		{	return EOS; }
[\ \t]*","[\ \t]*		{	return COMMA; }
[\ \t]*"="[\ \t]*		{	strcpy(yylval.lval_str,yytext);
							return EQ;
						}
[\ \t]*"!="[\ \t]*		{	strcpy(yylval.lval_str,yytext);
							return NQ;
						}
[\ \t]*"=="[\ \t]*		{ 	strcpy(yylval.lval_str,yytext);
							return EE;
						}
[\ \t]*"&&"[\ \t]*		{	strcpy(yylval.lval_str,yytext);
							return AND;
						}
[\ \t]*"||"[\ \t]*		{	strcpy(yylval.lval_str,yytext);
							return OR;
						}
""						{	return NONE; }
[\ \t]*"{"[\ \t]*		{	return L_BRACE; }
[\ \t]*"}"[\ \t]*		{	return R_BRACE; }
[\ \t]*"("[\ \t]*		{	return L_PAREN; }
[\ \t]*")"[\ \t]*		{	return R_PAREN; }
[\ \t]*"if"[\ \t]*		{	return IF; }
[\ \t]*"else"[\ \t]*	{	return ELSE; }

\".+\"					{	return RITERAL; }
[\ \t]+					{	return SP; }
[a-zA-Z_]+				{	strcpy(yylval.lval_str,yytext);
							return SYMBOL	;
						}
[1-9][0-9]* 			{	yylval.lval_num = atoi(yytext);
							return NUMBER;
						}
%%
