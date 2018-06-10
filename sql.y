%{
#include "sql.h"

char database[64]={0};

int yylex();
int yyparse();

void yyerror (const char *str) 
{
	fprintf(stderr, "error: %s\n", str);		// error function
}

int yywrap() 
{
	return 1;
}
// main function 
int main() 
{
	printf("SQL>");
	return	yyparse(); // calling parse funtion 
} 

%}

%union{  
	int intval;   
  	char *strval;
  	struct  hyper_items_def *Citemsval;
  	struct create_def *createval;
  	struct value_def *valueval;
  	struct item_def *itemval;
  	struct conditions_def *conval;
  	struct table_def *tbval;
  	struct upcon_def *updateval;
}

%token SELECT FROM WHERE AND OR DROP DELETE TABLE CREATE INTO VALUES INSERT UPDATE SET SHOW DATABASE DATABASES TABLES EXIT USE
%token <intval> NUMBER 
%token <strval> STRING ID INT CHAR
%type <intval> comparator ao
%type <Citemsval> hyper_items create_items
%type <createval> createsql
%type <valueval> value_list value
%type <itemval> item item_list
%type <conval> condition conditions
%type <tbval> tables
%type <updateval> up_cond up_conds
%left OR
%left AND


%%

/* production for sql grammar */

statements: statements statement | statement
statement: createsql | showsql | selectsql | insertsql | deletesql | updatesql | dropsql | exitsql | usesql

usesql: 		USE ID ';' '\n' {
					useDB($2);
					printf("SQL>");
		        }

showsql: 		SHOW DATABASES ';' '\n' {
		            showDB();
		            printf("SQL>");
		        }
		        |SHOW TABLES ';' '\n' {
		            showTable();
		            printf("SQL>");
		        }

createsql:		CREATE TABLE ID '(' hyper_items ')' ';' '\n' {
					$$ = ((struct create_def *)malloc(sizeof(struct create_def)));
                	$$->table = $3;
                	$$->Citems_def = $5;
                	createTable($$);
                	printf("SQL>");
				}

				|CREATE DATABASE ID ';' '\n' {
					strcpy(database, $3);
					createDB();
					printf("SQL>");
				}		        

selectsql: 		SELECT '*' FROM tables ';' '\n'{
					selectWhere(NULL, $4, NULL);
					printf("SQL>");
				}
				| SELECT item_list FROM tables ';' '\n' {
					selectWhere($2, $4, NULL);
					printf("SQL>");
				}		
				|SELECT '*' FROM tables WHERE conditions ';' '\n' {
					selectWhere(NULL, $4, $6);
					printf("SQL>");
				}
				|SELECT item_list FROM tables WHERE conditions ';' '\n' { 
					selectWhere($2, $4, $6);
					printf("SQL>");
				}

deletesql:		DELETE FROM ID ';' '\n' {
					deletes($3, NULL);
					printf("SQL>");
				}

				|DELETE FROM ID WHERE conditions ';' '\n' 	{ 
					deletes($3, $5);
					printf("SQL>");
				}


insertsql:		INSERT INTO ID VALUES '(' value_list ')' ';' '\n' {
					multiInsert($3, NULL, $6);
					printf("SQL>");
				}
		
				|INSERT INTO ID '(' item_list ')' VALUES '(' value_list ')' ';' '\n' {
					multiInsert($3, $5, $9);
					printf("SQL>");
				}


updatesql:		UPDATE ID SET up_conds ';' '\n' {
					updates($2, $4, NULL);
					printf("SQL>");
				}
		
				|UPDATE ID SET up_conds WHERE conditions ';' '\n' {
					updates($2, $4, $6);
					printf("SQL>");
				}

dropsql:		DROP TABLE ID ';' '\n'	{
					dropTable($3);
					printf("SQL>");
				}
				| DROP DATABASE ID ';' '\n' {
					dropDB($3);
					printf("SQL>");
				}

exitsql: 		EXIT ';' {
		            printf("exit with code 0!\n");
		            exit(0);
		        }

create_items:	ID INT {
					$$ = (struct hyper_items_def *)malloc(sizeof(struct hyper_items_def));
                    $$->field = $1;
                    $$->type = 0;	
                    $$->next = NULL;	
				}
				| ID CHAR '(' NUMBER ')'{
					$$ = (struct hyper_items_def *)malloc(sizeof(struct hyper_items_def));
                    $$->field = $1;
                    $$->type = 1;
                    $$->next = NULL;	
				}

hyper_items: 	create_items {
					$$ = $1;
				}
				| hyper_items ',' create_items {
					$$ = $3;
					$$->next = $1;				
				}

item: 			ID {
					$$ = (struct item_def *)malloc(sizeof(struct item_def));
					$$->field = $1;
					$$->pos = NULL;
					$$->next = NULL;
				}

item_list: 		item {
					$$ = $1;				
				}
				| item_list ',' item{
					$$ = $3;
					$$->next = $1;
				}

value:			NUMBER {
					$$ = ((struct value_def *)malloc(sizeof(struct value_def)));
					$$->value.intkey = $1;
					$$->type = 0;
					$$->next = NULL;
				}
				| STRING {
					$$ = ((struct value_def *)malloc(sizeof(struct value_def)));
					strcpy($$->value.skey, $1);
					$$->type = 1;
					$$->next = NULL;
				}

value_list:		value {
					$$ = $1;
				}
				| value_list ',' value {
					$$ = $3;
					$$->next = $1;
				}

comparator:		'=' {$$ = 1; }
				| '>' {$$ = 2; }
				| '<' {$$ = 3; }
				| ">=" {$$ = 4; }
				| "<=" {$$ = 5; }
				| '!' '=' {$$ = 6; }

ao: 			AND {$$ = 7; }
				| OR {$$ = 8; }

condition: 		item comparator NUMBER {
					$$ = ((struct conditions_def *)malloc(sizeof(struct conditions_def)));
					$$->type = 0;
					$$->litem = $1;
					$$->intv = $3;
					$$->cmp_op = $2;
					$$->left = NULL;
					$$->right = NULL;
				}
				| item comparator STRING {
					$$ = ((struct conditions_def *)malloc(sizeof(struct conditions_def)));
					$$->type = 1;
					$$->litem = $1;
					$$->strv = $3;
					$$->cmp_op = $2;
					$$->left = NULL;
					$$->right = NULL;
				}

conditions: 	condition {
					$$ = $1;
				}
				|'(' conditions ')' {
					$$ = $2;
				}
				| conditions ao condition {
					$$ = ((struct conditions_def *)malloc(sizeof(struct conditions_def)));
					$$->cmp_op = $2;
					$$->left = $1;
					$$->right = $3;
				}

tables:			ID {
					$$ = ((struct table_def *)malloc(sizeof(struct table_def)));
					$$->table = $1;
					$$->next = NULL;
				}
				| tables ',' ID{
					$$ = ((struct table_def *)malloc(sizeof(struct table_def)));
					$$->table = $3;
					$$->next = $1;				
				}

up_cond:		ID '=' NUMBER {
					$$ = ((struct upcon_def *)malloc(sizeof(struct upcon_def)));
					$$->field = $1;
					$$->type = 0;
					$$->value.intkey = $3;
					$$->next = NULL;
				}
				| ID '=' STRING {
					$$ = ((struct upcon_def *)malloc(sizeof(struct upcon_def)));
					$$->field = $1;
					$$->type = 1;
					strcpy($$->value.skey, $3);
					$$->next = NULL;				
				}

up_conds:		up_cond {
					$$ = $1;
				}
				| up_conds ',' up_cond {
					$$ = $3;
					$$->next = $1;
				}

%%
