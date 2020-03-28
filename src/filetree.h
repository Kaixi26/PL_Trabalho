#ifndef FILE_TREE_H
#define FILE_TREE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/stat.h>
#include <unistd.h>
#include "stringbuilder.h"

typedef struct s_ftree Filetree;

typedef enum {
    FT_FOLDER,
    FT_FILE
} filetree_t;

struct s_ftree {
    filetree_t type;
    char* name;
    Stringbuilder* contents;
    Filetree* parent;
    int next;
    int size;
    Filetree** children;
};

Filetree* filetree_init();
int filetree_mkdir(Filetree*, const char*);
int filetree_mkfile(Filetree*, const char*);
Filetree* filetree_cd(Filetree*, const char* name);
Filetree* filetree_open(Filetree*, const char* name);
void filetree_append(Filetree*, const char* text);
Filetree* filetree_moveup(Filetree*, int);
Filetree* filetree_toroot(Filetree*);
Filetree* filetree_search_file(Filetree*, char* path);
void filetree_print(Filetree*);
void filetree_build(Filetree*);
void filetree_free(Filetree*);

#endif