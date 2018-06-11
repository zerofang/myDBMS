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

typedef struct field{	/*field structure 字段结构体*/
    char name[64];		/*字段名*/
    int type;			/*INT:0  STRING:1*/
    union KEY key[100];		/*key 键值*/
}field;

typedef struct table{	/*table structure 表结构体*/
    char name[64];			/*表名*/
    struct field *ffield;	/*fields 字段数组指针*/
    int flen;			/*fields length 字段数目*/
    int ilen;			/*items length 记录条数*/
    struct table *next;
}table;

typedef struct mydb{	/*database structure 数据库结构体*/
    char name[64];		/*数据库名称*/
    struct table *tbroot;	/*table root 下属表链表的根节点*/
    struct mydb *next;
}mydb;

typedef struct hyper_items_def		/*CREATE语句后的字段和类型链表节点结构*/
{
	char *field;		/*字段名称*/
	int type;			/*INT:0  STRING:1*/
	struct  hyper_items_def *next;
}hyper_items_def;

typedef struct value_def	/*INSERT语句的键值链表节点结构，包括值和类型*/
{
	union KEY value;	/*值*/
	int type;		/*类型，INT:0  STRING:1*/
	struct value_def *next;
}value_def;

typedef struct item_def 	/*INSERT，SELECT语句的选择字段链表节点结构，包括字段名，字段位置指针*/
{
	char *field;	/*字段名*/
	struct field *pos;	/*字段在实际数据库中的位置指针*/
	struct item_def *next;
}field_def;

typedef struct conditions_def	/*SELECT,UPDATE,DELETE语句的条件二叉树节点结构*/
{
	int type; /*键值类型，INT:0  STRING:1*/	
	struct item_def *litem;		/*条件表达式左部的字段指针*/
	int intv;		/*整型键值存储处*/
	char *strv;		/*字符串键值*/
	int cmp_op;		/*操作符类型, '=':1 | '>':2 | '<':3 | '>=':4 | '<=':5 | '!=':6 | 'AND':7 | 'OR':8 */
	struct conditions_def *left;	/*左子树指针*/
	struct conditions_def *right;	/*右子树指针*/
}conditions_def;

typedef struct table_def	/*多表SELECT语句的表链表节点结构*/
{
	char *table;	/*表名*/
	struct table *pos;		/*表在实际数据库中的位置指针*/
	struct table_def *next;
}table_def;

typedef struct upcon_def	/*UPDATE语句的赋值链表节点结构*/
{
	char *field;	/*字段名*/
	int type;		/*类型，INT:0  STRING:1*/
	union KEY value;	/*值*/
	struct field *pos;		/*字段在实际数据库中的位置指针*/
	struct upcon_def *next;
}upcon_def;

void createDB();
void showDB();
void useDB(char *dbname);
void createTable(char *tableval, struct hyper_items_def *Hitemroot);
void showTable();
void multiInsert(char *tableval, struct item_def *itemroot, struct value_def *valroot);
void selectWhere(struct item_def *itemroot, struct table_def *tableroot, struct conditions_def *conroot);
void deletes(char *tableval, struct conditions_def *conroot);
void updates(char *tableval, struct upcon_def *uproot, struct conditions_def *conroot);
void dropTable(char *tableval);
void dropDB(char *dbname);

#endif