%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>
#define YYDEBUG 1
#define SIZ_BUF		(256)
#define	MAX_BRANCH	(10)
#define	MAX_DEPTH	(10)
extern int yylex(void);
extern int yyerror(char const *str);
extern char *yytext;
char g_func[SIZ_BUF];
int g_depth = 0;
bool g_is_branch = false;
typedef struct _BRANCH_SET
{
	char condition[MAX_BRANCH][SIZ_BUF];
	int free_idx;
} BRANCH_SET;
BRANCH_SET g_branch_set[MAX_DEPTH];
%}
%union{
	int		lval_num;
	char	lval_str[256];
}
%token		NUMBER SYMBOL
%token		ADD SUB TYPE RETURN CR EOS COMMA EQ AND OR IF
%token		SP RITERAL MARU_BRA L_BRA R_BRA NONE
%type		<lval_num> NUMBER
%type		<lval_str> SYMBOL ret expr condition func_def arg sp TYPE
%left		ADD SUB
%start		line
%%
line		:	CR
			|	line line	
			|	expr line			{	printf("%s\n",$1);	}
			|	ret line			{	printf("%s\n",$1);	}
			|	func_def line		{	printf("%s\n",$1);	}
			|	EOS line
			|	l_bra line
			|	r_bra line
			|	branch line
			|	variant_def line
			;
branch		:	IF sp MARU_BRA condition MARU_BRA	{	g_is_branch = true;
														g_branch_set[g_depth].free_idx++;
													}
			;
condition	:	expr sp AND sp expr	{	sprintf($$,"%s %s %s",$<lval_str>1,$<lval_str>2,$<lval_str>3);	}
			;
l_bra		:	L_BRA	{	if (true == g_is_branch)
							{
								g_depth++;
							}
						}
			;
r_bra		:	R_BRA	{	if (true == g_is_branch)
							{
								g_depth--;
								if (0 == g_depth)
								{
									g_is_branch = false;
								}
							}	
						}
			;
sp			:	SP							{	sprintf($$," ");	}
			|	NONE						{	sprintf($$,"%s",$<lval_str>1);	}
			;
expr		:	expr EOS					{	sprintf($$,"%s", $<lval_str>1); }
			|	MARU_BRA NUMBER MARU_BRA	{	sprintf($$,"%s%d%s",$<lval_str>1,$<lval_num>2,$<lval_str>3);	}
			|	MARU_BRA SYMBOL MARU_BRA	{	sprintf($$,"%s%s%s",$<lval_str>1,$<lval_str>2,$<lval_str>3);	}
			|	NUMBER 						{	sprintf($$,"%d",$<lval_num>1);	}
			|	SYMBOL						{	sprintf($$,"%s",$<lval_str>1);	}
			|	SYMBOL sp EQ sp expr		{	sprintf($$,"%s%s%s",$<lval_str>1,$<lval_str>2,$<lval_str>3);	}	
			;
ret			:	RETURN SP expr EOS			{	sprintf($$,"%s %s",$<lval_str>1,$<lval_str>3);	}
			;
variant_def	:	TYPE SP SYMBOL EOS
			;
func_def	:	TYPE SP SYMBOL MARU_BRA arg MARU_BRA	{	sprintf($$,"%s %s(%s)",$<lval_str>1,$<lval_str>2,$<lval_str>3);	printf("%s\n",$$);}
			;
arg			:	TYPE SP SYMBOL				{	sprintf($$,"%s %s",$<lval_str>1,$<lval_str>2);	}
			|	arg sp COMMA arg			{	sprintf($$,"%s,%s",$<lval_str>1,$<lval_str>4);	}
			|	sp							{	sprintf($$,"%s",$<lval_str>1);	}
			;
%%
int yyerror(char const *str)
{
	fprintf(stderr, "[E]:%s\n", yytext);
}

extern int yyparse(void);
extern int yylex(void);
extern FILE *yyin;
char buf[SIZ_BUF];
int main(void)
{

	memset((void*)&g_branch_set, 0x00, sizeof(BRANCH_SET) * MAX_DEPTH);

	FILE* fp;
	fp = fopen("./test.c", "r");
	if (!fp)
	{
		perror("fopen");
	}
	yyin = fp;
	/*
	while(fgets(buf, sizeof(buf), fp))
	{
		printf("%s\n",buf);
	}
	*/

/*
	yyin = stdin;
	*/
	while (yyparse()) {
		;
	}
}
