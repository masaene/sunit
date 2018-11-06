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
#define	STACK_MIN	(9)
#define	STACK_MAX	(0)
extern int yylex(void);
extern int yyerror(char const *str);
extern char *yytext;

void push(int a);
int pop(void);

char g_func[SIZ_BUF];
int g_depth = 0;
bool g_is_branch = false;
int g_stack[10];
int g_sp;
typedef struct _CONDITION
{
	char condition[SIZ_BUF];
	int free_idx;
} T_CONDITION;
%}
%union{
	int		lval_num;
	char	lval_str[256];
}
%token		NUMBER SYMBOL
%token		ADD SUB TYPE RETURN CR EOS COMMA EQ NQ EE AND OR IF ELSE
%token		SP RITERAL L_BRACE R_BRACE L_PAREN R_PAREN NONE
%type		<lval_num> NUMBER
%type		<lval_str> SYMBOL ret expr func_def var_def arg branch
%left		ADD SUB
%start		program
%%
program		:	program program
			|	EOS CR
			|	expr CR
			|	ret CR
			|	func_def CR
			|	branch CR
			|	var_def CR
			|	r_brace CR
			|	l_brace CR
			;

branch		:	IF L_PAREN expr R_PAREN		{
												sprintf($$,"if (%s)",$<lval_str>3);
												printf("%s\n",$$);
												push(1);
											}
			|	ELSE						{
												sprintf($$,"else");
												printf("%s\n",$$);
											}
			|	ELSE IF L_PAREN expr R_PAREN	{	
												sprintf($$,"else if");	
												push(2);
												}
			;

l_brace		:	L_BRACE				
			;

r_brace		:	R_BRACE						{	printf("%d\n",pop());	}
			;

/*
condition	:	expr sp AND sp expr	{	sprintf($$,"%s %s %s",$<lval_str>1,$<lval_str>3,$<lval_str>5);	}
			;
			*/

expr		:	L_PAREN NUMBER R_PAREN		{	sprintf($$,"(%d)",$<lval_num>2);	}
			|	L_PAREN SYMBOL R_PAREN		{	sprintf($$,"(%s)",$<lval_str>2);	}
			|	NUMBER 						{	sprintf($$,"%d",$<lval_num>1);	}
			|	SYMBOL						{	sprintf($$,"%s",$<lval_str>1);	}
			|	expr EQ expr 				{	sprintf($$,"%s=%s",$<lval_str>1,$<lval_str>3);	}	
			|	expr NQ expr 				{	sprintf($$,"%s!=%s",$<lval_str>1,$<lval_str>3);	}	
			|	expr EE expr 				{	sprintf($$,"%s==%s",$<lval_str>1,$<lval_str>3);	}
			|	expr AND expr				{	sprintf($$,"%s&&%s",$<lval_str>1,$<lval_str>3);	}
			|	expr EOS					{	sprintf($$,"%s",$<lval_str>1);	}	
			;

ret			:	RETURN SP expr EOS			{	sprintf($$,"%s %s",$<lval_str>1,$<lval_str>3);	}
			;

var_def		:	TYPE SP SYMBOL EOS			{	sprintf($$,"%s %s;",$<lval_str>1,$<lval_str>3);	}
			;

func_def	:	TYPE SP SYMBOL L_PAREN arg R_PAREN	{	sprintf($$,"%s %s(%s)",$<lval_str>1,$<lval_str>3,$<lval_str>5);	printf("%s\n",$$);}
			;

arg			:	TYPE SP SYMBOL				{	sprintf($$,"%s %s",$<lval_str>1,$<lval_str>3);	}
			|	arg COMMA arg				{	sprintf($$,"%s,%s",$<lval_str>1,$<lval_str>3);	}
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

void push(int a)
{
	if (STACK_MAX != g_sp)
	{
		g_stack[g_sp] = a;
		g_sp--;
	}
}

int pop(void)
{
	int ret;
	if (0 != g_sp)
	{
		ret = g_stack[g_sp];
		g_sp++;
		return ret;
	}
	return -1;
}

int main(void)
{

	g_sp = STACK_MIN;
	memset((void*)&g_branch_set, 0x00, sizeof(BRANCH_SET) * MAX_DEPTH);
	memset((void*)g_stack, 0x00, sizeof(g_stack));

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
