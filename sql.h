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
	char *field;
	struct item_def *next;
}field_def;

void createDB();
void createTable(struct create_def *Croot);
void singleInsert(char *tableval, struct value_def *valroot);
void multiInsert(char *tableval, struct item_def *itemroot, struct value_def *valroot);
void selectAll(char *tableval);

#endif