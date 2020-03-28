%option noyywrap

%x META TREE WR_FILE

/* whitespace characters */
ws [ \t\r\n\v\f]
/* non whitespace characters */
nws [^ \t\r\n\v\f]
/* letter, number or underscore*/
ln [A-Za-z0-9_]

%{
    #include <ctype.h>
    #include "metadata.h"
    #include "metastate.h"
    #include "filetree.h"
    #include "log.h"
    Metadata* metadata;
    Filetree* filetree;
    int filetree_depth = 0;
%}

%%

<WR_FILE>\\.*\n {
    Stringbuilder* sb = metadata_substitute(metadata, yytext+1);
    filetree_append(filetree, string_get(sb));
    string_free(sb);
}

<TREE,WR_FILE>^\=\=\=\ {nws}+\n {
    BEGIN WR_FILE;
    Stringbuilder* sb = metadata_substitute(metadata, yytext+4);
    char* path = strdup(string_get(sb));
    strchr(path, '\n')[0] = '\0';
    IF_LOG
        printf("Entering file '%s'.\n", path);
    filetree = filetree_toroot(filetree);
    filetree = filetree_search_file(filetree, path);
    if(!filetree){
        fprintf(stderr, "Could not find file.\n");
        exit(2);
    }
    string_free(sb);
    free(path);
}


<WR_FILE>.*\n {
    Stringbuilder* sb = metadata_substitute(metadata, yytext);
    filetree_append(filetree, string_get(sb));
    string_free(sb);
}

<WR_FILE>\\.* {
    Stringbuilder* sb = metadata_substitute(metadata, yytext+1);
    filetree_append(filetree, string_get(sb));
    string_free(sb);
}

<WR_FILE>.* {
    Stringbuilder* sb = metadata_substitute(metadata, yytext);
    filetree_append(filetree, string_get(sb));
    string_free(sb);
}

<META>^\=\=\=\ tree\n {
    LOG("Entering tree.");
    BEGIN TREE;
}

<TREE>#.*\n {
    LOG("Skipping comment line.");
}

<TREE>-*{ws}*{nws}+{ws}*\n {
    Stringbuilder* sb = metadata_substitute(metadata, yytext);
    char* tmp = strdup(string_get(sb));
    char* name;
    int depth = 0;
    int i;
    for(i=0; tmp[i] == '-'; i++) depth++;
    while(isspace(tmp[i])) i++;
    name = tmp+i;
    int slashes = 0;
    for(;!isspace(tmp[i]); i++)
        if(tmp[i] == '/') slashes++;
    tmp[i] = '\0';
    if(!(slashes == 0 || (slashes == 1 && tmp[i-1] == '/'))){
        fprintf(stderr, "Invalid value for folder '%s.\n", tmp);
        exit(1);
    }
    filetree = filetree_moveup(filetree, filetree_depth - depth);
    filetree_depth = depth;
    if(slashes == 0){
        filetree_mkfile(filetree, name);
    } else if (slashes == 1){
        tmp[i-1] = '\0';
        filetree_mkdir(filetree, name);
        filetree = filetree_cd(filetree, name);
        filetree_depth++;
    }
    IF_LOG
        printf("Added %s %s, current depth %d.\n", slashes ? "folder" : "file", name, filetree_depth);

}

<META>#>print{ws}*\n {
    IF_LOG
        metadata_print(metadata);
}

<META>#.*\n {
    LOG("Skipping comment line.");
}

<META>{ws}*{nws}+{ws}*\:{ws}*{nws}+{ws}*\n {
    int key_i = -1;
    int val_i = -1;
    metastate_getpairind(yytext, &key_i, &val_i);
    metadata_put(metadata, yytext+key_i, yytext+val_i);
    LOG("Found variable.");
}

<META>.*\n LOG("LINE WITHOUT EFFECT.");

^\=\=\=\ meta\n {
    LOG("Entering meta.");
    BEGIN META;
}



<*><<EOF>> {
    return(0);
}

%%

int main(int argc, char** argv){
    metadata = metadata_init();
    filetree = filetree_init();
    if(argc >= 2) metadata_put(metadata, "name", argv[1]);

    yylex();

    filetree = filetree_toroot(filetree);
    filetree_build(filetree);
    //filetree_print(filetree);

    return(0);
}