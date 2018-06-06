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
}

%token SELECT FROM WHERE AND OR DROP DELETE TABLE CREATE INTO VALUES INSERT UPDATE SET SHOW DATABASE DATABASES TABLES EXIT USE
%token <intval> NUMBER comparator ao
%token <strval> STRING ID INT CHAR
%type <Citemsval> hyper_items create_items
%type <createval> createsql
%type <valueval> value_list value
%type <itemval> item item_list
%type <conval> condition conditions
%type <tbval> tables
%left OR
%left AND

%%

/* production for sql grammar */

statements: statements statement | statement
statement: createsql | showsql | selectsql | insertsql | deletesql | updatesql | dropsql | exitsql | usesql

usesql: 		USE ID ';' '\n' {
					strcpy(database, $2);
		          	printf("using database %s\n",$2);
		        }

showsql: 		SHOW DATABASES ';' '\n' {
		            printf("show Databases \n");
		        }
		        |SHOW TABLES ';' '\n' {
		            printf("show Tables \n");
		        }

createsql:		CREATE TABLE ID '(' hyper_items ')' ';' '\n' {
					printf("creating table %s\n",$3);
					$$ = ((struct create_def *)malloc(sizeof(struct create_def)));
                	$$->table = $3;
                	$$->Citems_def = $5;
                	createTable($$);
				}

				|CREATE DATABASE ID ';' '\n' {
					strcpy(database, $3);
					printf("creating database \n"); 
					createDB();
				}		        

selectsql: 		SELECT '*' FROM ID ';' '\n' {
					selectAll($4);
					printf("all select with * \n");
				}
				| SELECT item_list FROM ID ';' '\n' {
					selectParts($2, $4);
					printf("Easy select with items \n"); 
				}			
				|SELECT '*' FROM tables WHERE conditions ';' '\n' {
					selectWhere(NULL, $4, $6);
					printf("conditional select with *  \n"); 
				}

				|SELECT item_list FROM tables WHERE conditions ';' '\n' { 
					selectWhere($2, $4, $6);
					printf("Conditional select with items \n");
				}

deletesql:		DELETE FROM ID ';' '\n' {
					printf("Deleting complete rows.\n");
				}

				|DELETE FROM ID WHERE conditions ';' '\n' 	{ printf("Deleting data from particular table.\n"); }


insertsql:		INSERT INTO ID VALUES '(' value_list ')' ';' '\n' {
					singleInsert($3, $6);
					printf("INSERTing INTO TABLE\n"); 
				}
		
				|INSERT INTO ID '(' item_list ')' VALUES '(' value_list ')' ';' '\n' {
					multiInsert($3, $5, $9);
				 	printf("INSERTing INTO TABLE with items\n"); 
				}


updatesql:		UPDATE ID SET up_cond ';' '\n' {
					printf("updating without condition\n" );
				}
		
				|UPDATE ID SET up_cond WHERE conditions ';' '\n' { printf("updating with nested condition\n" );};

dropsql:		DROP TABLE ID ';' '\n'	{printf("Dropping table.\n");}

exitsql: 		EXIT ';' {
		            printf("exit with code 0!\n");
		            exit(0);
		        }

create_items:	ID INT {
					$$ = (struct hyper_items_def *)malloc(sizeof(struct hyper_items_def));
                    $$->field = $1;
                    $$->type = $2;	
                    $$->next = NULL;	
				}
				| ID CHAR '(' NUMBER ')'{
					$$ = (struct hyper_items_def *)malloc(sizeof(struct hyper_items_def));
                    $$->field = $1;
                    $$->type = $2;
                    $$->next = NULL;	
				}

hyper_items: 	create_items {
					$$ = (struct hyper_items_def *)malloc(sizeof(struct hyper_items_def));
                    $$->field = $1->field;
                    $$->type = $1->type;
                    $$->next = NULL;
				}
				| hyper_items ',' create_items {
					$$ = (struct hyper_items_def *)malloc(sizeof(struct hyper_items_def));
                    $$->field = $3->field;
                    $$->type = $3->type;
                    $$->next = $1;					
				}

item: 			ID {
					$$ = (struct item_def *)malloc(sizeof(struct item_def));
					$$->table = NULL;
					$$->field = $1;
					$$->pos = NULL;
					$$->next = NULL;
				}
				|ID '.' ID{
					$$ = (struct item_def *)malloc(sizeof(struct item_def));
					$$->table = $1;
					$$->field = $3;
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

comparator:		'=' {$$ = 1}
				| '>' {$$ = 2}
				| '<' {$$ = 3}
				| ">=" {$$ = 4}
				| "<=" {$$ = 5}
				| '!' '=' {$$ = 6}

ao: 			AND {$$ = 7}
				| OR {$$ = 8}

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
				| item comparator item {
					$$ = ((struct conditions_def *)malloc(sizeof(struct conditions_def)));
					$$->type = 2;
					$$->litem = $1;
					$$->ritem = $3;
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

up_cond:		ID '=' STRING new_up_cond | ID '=' NUMBER new_up_cond ;

new_up_cond:	',' ID '=' STRING new_up_cond | ',' ID '=' NUMBER new_up_cond |/*e*/ ;

%%
