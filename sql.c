#include "sql.h"

extern char database[64];

struct mydb *dbroot = NULL;

struct item_def *converseItems(struct item_def *ppHead)  
{  
    struct item_def *pCurNode = ppHead; 
    struct item_def *pPrevNode = NULL;  
    struct item_def *pTmpNode = NULL;  
    while(pCurNode)  
    {  
        pPrevNode = pCurNode; 
        pCurNode = pCurNode->next;
        pPrevNode->next = pTmpNode;
        pTmpNode = pPrevNode;
    } 
    return pTmpNode;
} 

void createDB(){
	if(dbroot == NULL){
		dbroot = (struct mydb *)malloc(sizeof(struct mydb));
	    strcpy(dbroot->name,database);
	    dbroot->tbroot = NULL;
	    dbroot->next = NULL;
	    if(dbroot != NULL);
    		printf("Database %s created successfully!\n", database);
	    return;		
	}
	struct mydb *newdb;
	newdb = dbroot;
	while(newdb->next != NULL){
		if(strcmp(newdb->name,database) == 0){
			printf("error: The database already exists!\n");
			return;
		}
		newdb = newdb->next;
	}
	if(strcmp(newdb->name,database) == 0){
		printf("error: The database already exists!\n");
		return;
	}
	newdb->next = (struct mydb *)malloc(sizeof(struct mydb));
    strcpy(newdb->next->name,database);
    newdb->next->tbroot = NULL;
    newdb->next->next = NULL;
    if(dbroot->next != NULL);
    	printf("Database %s created successfully!\n", database);
}

void createTable(struct create_def *Croot){
	int i;
	struct mydb *dbtemp = NULL;
	struct table *newtable = NULL;
	struct table *tabletemp = NULL;
	struct hyper_items_def *itemstemp = Croot->Citems_def;
	if(dbroot != NULL)
		dbtemp = dbroot;
	else{
		printf("error: Please create a database first!\n");
		return;
	}
	while(dbtemp != NULL){
		if(strcmp(dbtemp->name,database) == 0){
			if(dbtemp->tbroot == NULL){
				dbtemp->tbroot = (struct table *)malloc(sizeof(struct table));
				strcpy(dbtemp->tbroot->name, Croot->table);
				dbtemp->tbroot->ffield = (struct field *)malloc(10*sizeof(struct field));
				i = 0;
				while(itemstemp != NULL && i<10){
					strcpy(dbtemp->tbroot->ffield[i].name, itemstemp->field);
					if(strcmp(itemstemp->type,"INT") == 0)
						dbtemp->tbroot->ffield[i].type = 0;
					else
						dbtemp->tbroot->ffield[i].type = 1;
					itemstemp = itemstemp->next;
					i++;
				}
				dbtemp->tbroot->flen = i;
				dbtemp->tbroot->ilen = 0;
				dbtemp->tbroot->next = NULL;
				if(dbtemp->tbroot != NULL)
					printf("Table %s created successfully!\n", Croot->table);		
				return;		
			}
			newtable = dbtemp->tbroot;
			while(newtable->next != NULL){
				if(strcmp(newtable->name,Croot->table) == 0){
					printf("error: The table already exists!\n");
					return;
				}
				newtable = newtable->next;
			}
			if(strcmp(newtable->name,Croot->table) == 0){
				printf("error: The table already exists!\n");
				return;
			}
			newtable->next = (struct table *)malloc(sizeof(struct table));
			strcpy(newtable->next->name, Croot->table);
			newtable->next->ffield = (struct field *)malloc(10*sizeof(struct field));
			i = 0;
			while(itemstemp != NULL && i<10){
				strcpy(newtable->next->ffield[i].name, itemstemp->field);
				if(strcmp(itemstemp->type,"INT") == 0)
					newtable->next->ffield[i].type = 0;
				else
					newtable->next->ffield[i].type = 1;
				itemstemp = itemstemp->next;
				i++;
			}
			newtable->next->flen = i;
			newtable->next->next = NULL;
			printf("Table %s created successfully!\n", Croot->table);
			return;
		}
		dbtemp = dbtemp->next;
	}
	printf("error: Database %s doesn't exist!\n", database);
}

void singleInsert(char *tableval, struct value_def *valroot){
	struct mydb *dbtemp = NULL;
	struct table *tabletemp = NULL;
	int i,temp;
	if(dbroot != NULL)
		dbtemp = dbroot;
	else{
		printf("error: Please create a database first!\n");
		return;
	}
	while(dbtemp != NULL){
		if(strcmp(dbtemp->name,database) == 0){
			tabletemp = dbtemp->tbroot;
			while(tabletemp != NULL){
				if(strcmp(tabletemp->name, tableval) == 0){
					i = 0;
					temp = tabletemp->ilen;
					while(valroot != NULL){
						if(valroot->type == 0){
							tabletemp->ffield[i].type = 0;
							tabletemp->ffield[i].key[temp].intkey = valroot->value.intkey;
						}
						else{
							tabletemp->ffield[i].type = 1;
							strcpy(tabletemp->ffield[i].key[temp].skey, valroot->value.skey);
						}
						i++;
						valroot = valroot->next;
					}
					if(i <= tabletemp->flen){
						temp++;
						tabletemp->ilen = temp;
						printf("Insert successfully!\n");						
					}
					else{
						printf("error: The number of supplied values does not match the table definition!\n");
					}
					return;
				}
				tabletemp = tabletemp->next;
			}
			printf("error: The table doesn't exist!\n");
			return;
		}
		dbtemp = dbtemp->next;
	}
	printf("error: Database %s doesn't exist!\n", database);
}

void multiInsert(char *tableval, struct item_def *itemroot, struct value_def *valroot){
	struct mydb *dbtemp = NULL;
	struct table *tabletemp = NULL;
	int i,j,temp;
	if(dbroot != NULL)
		dbtemp = dbroot;
	else{
		printf("error: Please create a database first!\n");
		return;
	}
	while(dbtemp != NULL){
		if(strcmp(dbtemp->name,database) == 0){
			tabletemp = dbtemp->tbroot;
			while(tabletemp != NULL){
				if(strcmp(tabletemp->name, tableval) == 0){
					temp = tabletemp->ilen;
					i = 0;
					while(itemroot != NULL && valroot != NULL){
						for(j = 0; j < tabletemp->flen; j++){
							if(strcmp(tabletemp->ffield[j].name,itemroot->field) == 0){
								if(valroot->type == 0){
									tabletemp->ffield[j].type = 0;
									tabletemp->ffield[j].key[temp].intkey = valroot->value.intkey;
								}
								else{
									tabletemp->ffield[j].type = 1;
									strcpy(tabletemp->ffield[j].key[temp].skey, valroot->value.skey);
								}
								i++;
								break;
							}
						}
						if(j == tabletemp->flen){
							printf("error: Column name does not match the table definition!\n");
							return;
						}
						itemroot = itemroot->next;
						valroot = valroot->next;
					}
					if(i <= tabletemp->flen && itemroot == NULL && valroot == NULL){
						temp++;
						tabletemp->ilen = temp;
						printf("Insert successfully!\n");						
					}
					else{
						printf("error: The number of supplied values does not match the table definition!\n");
					}
					return;
				}
				tabletemp = tabletemp->next;
			}
			printf("error: The table doesn't exist!\n");
			return;
		}
		dbtemp = dbtemp->next;
	}
	printf("error: Database %s doesn't exist!\n", database);
}

void selectAll(char *tableval){
	struct mydb *dbtemp = NULL;
	struct table *tabletemp = NULL;
	int i,j;
	if(dbroot != NULL)
		dbtemp = dbroot;
	else{
		printf("error: Please create a database first!\n");
		return;
	}
	while(dbtemp != NULL){
		if(strcmp(dbtemp->name,database) == 0){
			tabletemp = dbtemp->tbroot;
			while(tabletemp != NULL){
				if(strcmp(tabletemp->name, tableval) == 0){
					for(i = tabletemp->flen-1; i >= 0; i--){
						printf("%-20s  ", tabletemp->ffield[i].name);
					}
					printf("\n");
					for(j = 0; j < tabletemp->ilen; j++){
						for(i = tabletemp->flen-1; i >= 0; i--){
							if(tabletemp->ffield[i].type == 0)
								printf("%-20d  ", tabletemp->ffield[i].key[j].intkey);
							else
								printf("%-20s  ", tabletemp->ffield[i].key[j].skey);
						}
						printf("\n");						
					}
					return;
				}
				tabletemp = tabletemp->next;
			}
			printf("error: The table doesn't exist!\n");
			return;
		}
		dbtemp = dbtemp->next;
	}
	printf("error: Database %s doesn not exist!\n", database);
}

void selectParts(struct item_def *itemroot, char *tableval){
	struct mydb *dbtemp = NULL;
	struct table *tabletemp = NULL;
	struct item_def *itemtemp = NULL;
	itemroot = converseItems(itemroot);
	int i,j;
	if(dbroot != NULL)
		dbtemp = dbroot;
	else{
		printf("error: Please create a database first!\n");
		return;
	}
	while(dbtemp != NULL){
		if(strcmp(dbtemp->name,database) == 0){
			tabletemp = dbtemp->tbroot;
			while(tabletemp != NULL){
				if(strcmp(tabletemp->name, tableval) == 0){
					itemtemp = itemroot;
					while(itemtemp != NULL){
						for(i = 0; i < tabletemp->flen; i++){
							if(strcmp(itemtemp->field, tabletemp->ffield[i].name) == 0){
								itemtemp->pos = tabletemp->ffield[i];
								break;
							}
						}
						if(i == tabletemp->flen){
							printf("error: Column name does not match the table definition!\n");
							return;
						}
						itemtemp = itemtemp->next;
					}
					itemtemp = itemroot;
					while(itemtemp != NULL){
						printf("%-20s  ", itemtemp->field);
						itemtemp = itemtemp->next;
					}
					printf("\n");
					for(j = 0; j < tabletemp->ilen; j++){
						itemtemp = itemroot;
						while(itemtemp != NULL){
							if(itemtemp->pos.type == 0)
								printf("%-20d  ", itemtemp->pos.key[j].intkey);
							else
								printf("%-20s  ", itemtemp->pos.key[j].skey);
							itemtemp = itemtemp->next;	
						}
						printf("\n");					
					}
					return;
				}
				tabletemp = tabletemp->next;
			}
			printf("error: The table doesn't exist!\n");
			return;
		}
		dbtemp = dbtemp->next;
	}
	printf("error: Database %s doesn't exist!\n", database);	
}

_Bool whereTF(int i, int j, struct table_def *tableroot, struct conditions_def *conroot){
	int k;
	if(conroot->com_op == 7){
		return whereTF(i, j, tableroot, conroot->left) && whereTF(i, j, tableroot, conroot->right);
	}
	else if(conroot->com_op == 7){
		return whereTF(i, j, tableroot, conroot->left) || whereTF(i, j, tableroot, conroot->right);
	}
	else{
		if(conroot->litem->pos == NULL){
			struct table_def *tbtemp; 
			tbtemp = tableroot;
			while(tbtemp != NULL){
				for(k = 0; k < tbtemp->pos->flen; k++){
					if(strcmp(tbtemp->pos->ffield[k].name, conroot->litem->field) == 0){
						conroot->litem->pos = tbtemp->pos->ffield[k];
						break;
					}
				}
				if(strcmp(tbtemp->pos->ffield[k].name, conroot->litem->field) == 0)
					break;
			}
			if(conroot->litem->pos == NULL){
				
			}
		}
		if(conroot->type == 2 && conroot->ritem->pos == NULL){
			for(k = 0; k < tableroot->next->pos->flen; k++){
				if(strcmp(tableroot->pos->ffield[k].name, conroot->ritem->field) == 0){
					conroot->litem->pos = tableroot->pos->ffield[k];
				}
			}			
		}
	}
}

void selectWhere(struct item_def *itemroot, struct table_def *tableroot, struct conditions_def *conroot){
	struct mydb *dbtemp = NULL;
	struct table_def *tableptr = NULL;
	struct table *tabletemp = NULL;
	struct item_def *itemtemp = NULL;
	int i;
	itemroot = converseItems(itemroot);
	if(dbroot != NULL)
		dbtemp = dbroot;
	else{
		printf("error: Please create a database first!\n");
		return;
	}
	while(dbtemp != NULL){
		if(strcmp(dbtemp->name,database) == 0){
			tableptr = tableroot;
			while(tableptr != NULL){
				tabletemp = dbtemp->tbroot;
				while(tabletemp != NULL){
					if(strcmp(tabletemp->name, tableptr->table) == 0){
						tableptr->pos = tabletemp;
						break;
					}
					tabletemp = tabletemp->next;
				}
				if(tabletemp == NULL){
					printf("error: 	Table %s doesn't exist!\n", tableptr->table);
					return;
				}
				tableptr = tableptr->next;
			}
			itemtemp = itemroot;
			while(itemtemp != NULL){
				if(itemtemp->table  == NULL){
					tableptr = tableroot;
					while(tableptr != NULL){
						for (int i = 0; i < tableptr->pos->flen; ++i){
							if(strcmp(itemtemp->field, tableptr->pos->ffield[i].name) == 0){
								itemtemp->pos = tableptr->pos->ffield[i];
								break;
							}
						}
						if(strcmp(itemtemp->field, tableptr->pos->ffield[i].name) == 0)
							break;
						tableptr = tableptr->next;
					}
					if(itemtemp->pos = NULL){
						printf("error: 	Field %s doesn't exist!\n", itemtemp->field);
						return;						
					}
				}
				else{
					tableptr = tableroot;
					while(tableptr != NULL){
						if(strcmp(tableptr->table, itemtemp->table) == 0){
							for (int i = 0; i < tableptr->pos->flen; ++i){
								if(strcmp(itemtemp->field, tableptr->pos->ffield[i].name) == 0){
									itemtemp->pos = tableptr->pos->ffield[i];
									break;
								}
							}
							if(i == tableptr->pos->flen){
								printf("error: 	Field %s doesn't exist!\n", itemtemp->field);
								return;	
							}
							break;
						}
						tableptr = tableptr->next;
					}					
				}
				itemtemp = itemtemp->next;
			}
			if(tableroot->next == NULL){

			}
			else{
				tabletemp = (struct table *)malloc(sizeof(struct table));
				strcpy(tabletemp->name, "newtable");
				tabletemp->ffield = (struct field *)malloc(10*sizeof(struct field));
				i = 0;
				while(itemstemp != NULL && i<10){
					strcpy(tabletemp->ffield[i].name, itemstemp->field);
					if(strcmp(itemstemp->type,"INT") == 0)
						tabletemp->ffield[i].type = 0;
					else
						tabletemp->ffield[i].type = 1;
					itemstemp = itemstemp->next;
					i++;
				}
				tabletemp->flen = i;
				tabletemp->next = NULL;
			}
		}
		dbtemp = dbtemp->next;
	}
	printf("error: Database %s doesn't exist!\n", database);
}