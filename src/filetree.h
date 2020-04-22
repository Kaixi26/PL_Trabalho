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

/* Allocate space for the filetree */
Filetree* filetree_init();
/* Makes a directory in the current root */
int filetree_mkdir(Filetree*, const char*);
/* Creates a new file in the current directory */
int filetree_mkfile(Filetree*, const char*);
/* Changes to a child directory and returns it */
Filetree* filetree_cd(Filetree*, const char*);
/* Opens a file and returns it */
Filetree* filetree_open(Filetree*, const char* name);
/* Appends a string to the file */
void filetree_append(Filetree*, const char* text);
/* Moves up 'int' directories */
Filetree* filetree_moveup(Filetree*, int);
/* Moves filetree to main root */
Filetree* filetree_toroot(Filetree*);
/* Opens a file given the full path from current directory */
Filetree* filetree_search_file(Filetree*, char* path);
/* Prints the filetree in a human readable way */
void filetree_print(Filetree*);
/* Writes the filetree to the system, will exit program in case of failure */
void filetree_build(Filetree*);
/* Frees the space allocated for the filetree */
void filetree_free(Filetree*);

#endif