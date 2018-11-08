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

#define	LOG(fmt, ...)	{ \
	char log_msg[SIZ_BUF]; \
	sprintf(log_msg, fmt, ##__VA_ARGS__); \
	printf("[LOG]:%s@%d\t : %s\n",__func__,__LINE__,log_msg); \
}

extern int yylex(void);
extern int yyerror(char const *str);
extern char *yytext;

typedef struct ST_CONDITION_SET
{
	char						condition_str[SIZ_BUF];
	int 						widx;
	struct ST_CONDITION_SET*	parent;
	struct ST_CONDITION_SET*	child[MAX_CONDITION];
} T_CONDITION_SET;

typedef struct ST_FUNC_SET
{
	char				func_name[SIZ_BUF];
	int 				widx;
	T_CONDITION_SET*	p_condition;
} T_FUNC_SET;

T_FUNC_SET g_func;
T_CONDITION_SET* gp_current_con_set = NULL;
int g_brace_depth = 0;

char* trim_indent(char* p_str);
void print_func(void);
void re_print_func(T_CONDITION_SET* p_con_set);
void init_func(char* func_name);
void push(char* condition);
int pop(void);


%}
%union{
	int		lval_num;
	char	lval_str[256];
}
%token		NUMBER SYMBOL
%token		ADD SUB TYPE RETURN CR EOS COMMA EQ NQ EE AND OR IF ELSE 
%token		SP RITERAL L_BRACE R_BRACE L_PAREN R_PAREN NONE
%type		<lval_num> NUMBER
%type		<lval_str> SYMBOL ret expr func_def var_def arg branch operator primary sp
%type		<lval_str> l_brace r_brace l_paren r_paren
%left		ADD SUB
%start		program
%%
program		:	program program
			|	EOS CR
			|	sp CR
			|	ret CR
			|	primary CR
			|	func_def CR
			|	branch CR
			|	var_def CR
			|	r_brace CR
			|	l_brace CR
			;

branch		:	sp IF sp L_PAREN expr R_PAREN				{
														sprintf($$,"if (%s)",$<lval_str>5);
														push($$);
													}
			|	sp ELSE sp								{
														sprintf($$,"else");
														push(NULL);
													}
			|	sp ELSE sp IF L_PAREN expr R_PAREN		{	
														sprintf($$,"else if");	
														push($<lval_str>6);
													}
			;

l_brace		:	sp L_BRACE sp								{
														sprintf($$,"%s",$<lval_str>2);
														g_brace_depth++;
													}
			;

r_brace		:	sp R_BRACE sp								{
														sprintf($$,"%s",$<lval_str>2);
														g_brace_depth--;
														if (0 == g_brace_depth)
														{
															print_func();
														}
													}
			;

l_paren		:	L_PAREN								{	sprintf($$,"%s",$<lval_str>1);
													}
			;

r_paren		:	R_PAREN								{	sprintf($$,"%s",$<lval_str>1);
													}
			;

operator	:	NQ												{	sprintf($$,"%s",trim_indent($<lval_str>1));	}
			|	EE												{	sprintf($$,"%s",trim_indent($<lval_str>1));	}
			|	AND												{	sprintf($$,"%s",trim_indent($<lval_str>1));	}
			|	OR												{	sprintf($$,"%s",trim_indent($<lval_str>1));	}
			;

primary		:	sp l_paren expr r_paren sp 	EOS {	sprintf($$,"%s",$<lval_str>3);	}
			|	expr EOS					{	sprintf($$,"%s",$<lval_str>1);	}
			;

expr		:	sp primary sp operator sp primary sp {	sprintf($$,"%s%s%s",$<lval_str>2,$<lval_str>4,$<lval_str>6);	}
			|	sp SYMBOL sp EQ sp expr sp {	sprintf($$,"%s%s%s",$<lval_str>2,$<lval_str>4,$<lval_str>6);	}
			|	sp NUMBER sp									{	sprintf($$,"%d",$<lval_num>2);	}
			|	sp SYMBOL sp									{	sprintf($$,"%s",$<lval_str>2);	}
			;

ret			:	sp RETURN primary EOS 								{	sprintf($$,"%s%s",$<lval_str>2,$<lval_str>3);	}
			;

sp			:													{	sprintf($$," ");	}
			|	SP												{	sprintf($$,"%s",$<lval_str>1);	}
			;
var_def		:	sp TYPE sp SYMBOL sp EOS 								{	sprintf($$,"%s%s",$<lval_str>2,$<lval_str>4);	}
			;

func_def	:	sp TYPE sp SYMBOL sp l_paren arg r_paren		{
																	sprintf($$,"%s%s(%s)",$<lval_str>2,$<lval_str>4,$<lval_str>7);
																	init_func($<lval_str>4);
																}
			;

arg			:	sp TYPE sp SYMBOL sp							{	sprintf($$,"%s%s",$<lval_str>2,$<lval_str>4);	}
			|	arg COMMA arg 									{	sprintf($$,"%s,%s",$<lval_str>1,$<lval_str>3);	}
			;
%%
int yyerror(char const *str)
{
	fprintf(stderr, "[E]:\"%s\"\n", yytext);
}

extern int yyparse(void);
extern int yylex(void);
extern FILE *yyin;

char* trim_indent(char* p_str)
{
	char org_buf[SIZ_BUF];
	char* pos;

	strcpy(org_buf,p_str);
	pos = org_buf;

	while ((' ' == *pos) || ('\t' == *pos)) pos++;
	strcpy(p_str,pos);
	while ((0x20 < *pos) && ('\0' != *pos)) pos++;
	if ('\0' != *pos)
	{
		*pos = '\0';
	}
	return p_str;
}

void print_func(void)
{
	T_CONDITION_SET* p_con_set;
	printf("----------\n");
	printf("%s\n",g_func.func_name);

	p_con_set = g_func.p_condition;
	re_print_func(p_con_set);
	printf("----------\n");
}

void re_print_func(T_CONDITION_SET* p_con_set)
{
	for (int con_idx=0; con_idx<p_con_set->widx; con_idx++)
	{
		if (NULL != p_con_set->child[con_idx])
		{
			re_print_func(p_con_set->child[con_idx]);
		}
		else
		{
			printf("%s\n",p_con_set->condition_str);
		}
	}
}

void init_func(char* p_func_name)
{
	memset((void*)&g_func, 0x00, sizeof(T_FUNC_SET));
	strcpy(g_func.func_name,p_func_name);
	gp_current_con_set = NULL;
}

void push(char* p_condition)
{
	T_CONDITION_SET* p_con_set;

	p_con_set = (T_CONDITION_SET*)malloc(sizeof(T_CONDITION_SET));
	memset((void*)p_con_set, 0x00, sizeof(T_CONDITION_SET));

	if (NULL == gp_current_con_set)
	{
		g_func.p_condition = p_con_set;
		p_con_set->widx++;
	}
	else
	{
		gp_current_con_set->child[gp_current_con_set->widx] = p_con_set;
		p_con_set->parent = gp_current_con_set;
		p_con_set->parent->widx++;
		p_con_set->widx++;
	}

	gp_current_con_set = p_con_set;
	if (NULL == p_condition)
	{
		strcpy(p_con_set->condition_str,"!");
		strcat(p_con_set->condition_str,p_con_set->parent->condition_str);
	}
	else
	{
		strcpy(p_con_set->condition_str,p_condition);
	}

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
		gp_current_con_set = parent_con;
		gp_current_con_set->widx++;
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
	yyin = stdin;
	*/
	while (yyparse()) {
		;
	}
}
