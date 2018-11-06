%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>

#define YYDEBUG 1
#define SIZ_BUF				(256)
#define	MAX_CONDITION		(10)
#define	MAX_BRANCH			(10)
#define	STACK_MIN			(9)
#define	STACK_MAX			(0)

extern int yylex(void);
extern int yyerror(char const *str);
extern char *yytext;

void init_func(char* func_name);
void push(char* condition);
int pop(void);

typedef struct ST_CONDITION_SET
{
	char						condition_str[SIZ_BUF];
	int 						widx;
	struct ST_CONDITION_SET*	parent;
	struct ST_CONDITION_SET*	child[MAX_BRANCH];
} T_CONDITION_SET;

typedef struct ST_FUNC_SET
{
	char				func_name[SIZ_BUF];
	int 				widx;
	T_CONDITION_SET*	p_condition[MAX_CONDITION];
} T_FUNC_SET;

T_FUNC_SET g_func;
T_CONDITION_SET* gp_current_con_set = NULL;

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
												push($$);
											}
			|	ELSE						{
												sprintf($$,"else");
												printf("%s\n",$$);
											}
			|	ELSE IF L_PAREN expr R_PAREN	{	
												sprintf($$,"else if");	
												}
			;

l_brace		:	L_BRACE				
			;

r_brace		:	R_BRACE					
			;

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

void init_func(char* func_name)
{
	memset((void*)&g_func, 0x00, sizeof(T_FUNC_SET));
	strcpy(g_func.func_name,func_name);
}

void push(char* condition)
{
	T_CONDITION_SET* p_con_set;

	p_con_set = (T_CONDITION_SET*)malloc(sizeof(T_CONDITION_SET));

	if (NULL == gp_current_con_set)
	{
		g_func.p_condition[g_func.widx] = p_con_set;
		g_func.widx++;
	}
	else
	{
		gp_current_con_set->child[gp_current_con_set->widx] = p_con_set;
		p_con_set->widx++;
	}

	gp_current_con_set = p_con_set;
	strcpy(p_con_set->condition_str,condition);

	return;
}

int pop(void)
{
	T_CONDITION_SET* parent_con;

	if (NULL == gp_current_con_set->parent)
	{
		gp_current_con_set = NULL;
	}
	else
	{
		parent_con = gp_current_con_set;
	}
}

int main(void)
{



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
