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
"+"		{	return ADD; }
"-"		{	return SUB; }
"int"		{	strcpy(yylval.lval_str,yytext);
							return TYPE;
						}
return	{	return RETURN; }
"\n"					{	return CR; }
";"		{	return EOS; }
","		{	return COMMA; }
"="		{	strcpy(yylval.lval_str,yytext);
							return EQ;
						}
"!="		{	strcpy(yylval.lval_str,yytext);
							return NQ;
						}
"=="		{ 	strcpy(yylval.lval_str,yytext);
							return EE;
						}
"&&"		{	strcpy(yylval.lval_str,yytext);
							return AND;
						}
"||"		{	strcpy(yylval.lval_str,yytext);
							return OR;
						}
""						{	return NONE; }
"{"		{	return L_BRACE; }
"}"		{	return R_BRACE; }
"("		{	return L_PAREN; }
")"		{	return R_PAREN; }
"if"		{	return IF; }
"else"	{	return ELSE; }

\".+\"					{	return RITERAL; }
[\ \t]*					{	return SP; }
[a-zA-Z_]+				{	strcpy(yylval.lval_str,yytext);
							return SYMBOL	;
						}
[1-9]?[0-9]+ 			{	yylval.lval_num = atoi(yytext);
							return NUMBER;
						}
%%
