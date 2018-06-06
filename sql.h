#ifndef _SQL_H
#define _SQL_H

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

typedef union KEY{
	int intkey;
	char skey[64];
}KEY;

typedef struct field{
    char name[64];
    int type;			/*INT:0  STRING:1*/
    union KEY key[100];
}field;

typedef struct table{
    char name[64];
    struct field *ffield;
    int flen;	/*ziduanshu*/
    int ilen;
    struct table *next;
}table;

typedef struct mydb{
    char name[64];
    struct table *tbroot;
    struct mydb *next;
}mydb;

typedef struct hyper_items_def
{
	char *field;
	char *type;
	struct  hyper_items_def *next;
}hyper_items_def;

typedef struct create_def
{
	char *table;
	struct  hyper_items_def *Citems_def;
}create_def;

typedef struct value_def
{
	union KEY value;
	int type;
	struct value_def *next;
}value_def;

typedef struct item_def
{
	char *table;
	char *field;
	struct field *pos;
	struct item_def *next;
}field_def;

typedef struct conditions_def
{
	int type; /*int:0  str:1  item:2 */	
	struct item_def *litem;
	struct item_def *ritem;
	int intv;
	char *strv;
	int cmp_op;
	struct conditions_def *left;
	struct conditions_def *right;
}conditions_def;

typedef struct table_def
{
	char *table;
	struct table *pos;
	struct table_def *next;
}table_def;

void createDB();
void createTable(struct create_def *Croot);
void singleInsert(char *tableval, struct value_def *valroot);
void multiInsert(char *tableval, struct item_def *itemroot, struct value_def *valroot);
void selectAll(char *tableval);
void selectParts(struct item_def *itemroot, char *tableval);
void selectWhere(struct item_def *itemroot, struct table_def *tableroot, struct conditions_def *conroot);

#endif