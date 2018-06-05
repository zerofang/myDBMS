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
}

%token SELECT FROM WHERE AND OR DROP DELETE TABLE CREATE INTO VALUES INSERT UPDATE SET SHOW DATABASE DATABASES TABLES EXIT USE
%token <intval> NUMBER
%token <strval> STRING ID INT CHAR
%type <Citemsval> hyper_items create_items
%type <createval> createsql
%type <valueval> value_list value
%type <itemval> item item_list
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

selectsql: 		SELECT item_list FROM ID ';' '\n' {
					printf("Easy select with items \n"); 
				}
				|SELECT item_list using condition ';' '\n' { printf("Conditional select with items \n");}

				|SELECT '*' FROM ID ';' '\n' {
					selectAll($4);
					printf("all select with * \n");
				}
				
				|SELECT '*' using condition ';' '\n' { printf("conditional select with *  \n"); }


deletesql:		DELETE FROM ID ';' '\n' {
					printf("Deleting complete rows.\n");
				}

				|DELETE FROM ID WHERE condition ';' '\n' 	{ printf("Deleting data from particular table.\n"); }


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
		
				|UPDATE ID SET up_cond WHERE condition ';' '\n' { printf("updating with nested condition\n" );};

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
					$$->field = $1;
					$$->next = NULL;
				}

item_list: 		item {
					$$ = (struct item_def *)malloc(sizeof(struct item_def));
					$$->field = $1->field;
					$$->next = NULL;					
				}
				| item_list ',' item{
					$$ = (struct item_def *)malloc(sizeof(struct item_def));
					$$->field = $3->field;
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
					$$ = ((struct value_def *)malloc(sizeof(struct value_def)));
					$$->value = $1->value;
					$$->type = $1->type;
					$$->next = NULL;
				}
				| value_list ',' value {
					$$ = ((struct value_def *)malloc(sizeof(struct value_def)));
					$$->value = $3->value;
					$$->type = $3->type;
					$$->next = $1;
				}


comparator:		'=' | "<=" | '<' | '>' | ">=" | '!' '=' ;

ao: 			AND | OR ; 

using: 			FROM nes2 WHERE;

nes2: 			ID |/*e*/ ;

up_cond:		ID '=' STRING new_up_cond | ID '=' NUMBER new_up_cond;

new_up_cond:	',' ID '=' STRING new_up_cond | ',' ID '=' NUMBER new_up_cond |/*e*/ ;

condition: 		ID comparator STRING new_condition | ID comparator NUMBER new_condition;

new_condition: 	ao ID comparator STRING new_condition | ao ID comparator NUMBER new_condition | /*e*/;

%%
