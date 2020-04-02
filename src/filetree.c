#include "filetree.h"

Filetree* filetree_init_(filetree_t type, const char* name, Filetree* parent){
    Filetree* ft = malloc(sizeof(Filetree));
    ft->type = type;
    ft->name = name ? strdup(name) : NULL;
    ft->contents = type == FT_FILE ? string_init() : NULL;
    ft->parent = parent;
    ft->next = 0;
    ft->size = 0;
    ft->children = NULL;
    return ft;
}

Filetree* filetree_init(){
    return filetree_init_(FT_FOLDER, NULL, NULL);
}

void filetree_expand(Filetree* ft){
    if(ft->size == 0) ft->size = 1;
    else ft->size *= 2;
    ft->children = realloc(ft->children, ft-> size * sizeof(Filetree*));
}

int filetree_mkdir(Filetree* ft, const char* name){
    if(ft->type != FT_FOLDER)
        return -1;
    for(int i=0; i<ft->next; i++)
        if(ft->children[i]->type == FT_FOLDER && !strcmp(ft->children[i]->name, name))
            return -1;
    if(ft->next <= ft->size)
        filetree_expand(ft);
    ft->children[ft->next++] = filetree_init_(FT_FOLDER, name, ft);
    return 0;
}

int filetree_mkfile(Filetree* ft, const char* name){
    if(ft->type != FT_FOLDER)
        return -1;
    for(int i=0; i<ft->next; i++)
        if(ft->children[i]->type == FT_FILE && !strcmp(ft->children[i]->name, name))
            return -1;
    if(ft->next <= ft->size)
        filetree_expand(ft);
    ft->children[ft->next++] = filetree_init_(FT_FILE, name, ft);
    return 0;
}

Filetree* filetree_cd(Filetree* ft, const char* name){
    for(int i=0; i<ft->next; i++)
        if(ft->children[i]->type == FT_FOLDER && !strcmp(ft->children[i]->name, name))
            return ft->children[i];
    return NULL;
}

Filetree* filetree_open(Filetree* ft, const char* name){
    for(int i=0; i<ft->next; i++)
        if(ft->children[i]->type == FT_FILE && !strcmp(ft->children[i]->name, name))
            return ft->children[i];
    return NULL;
}

Filetree* filetree_moveup(Filetree* ft, int upleft){
    for(int i=upleft; i > 0; i--){
        if(ft->parent)
            ft = ft->parent;
        else break;
    }
    return ft;
}

Filetree* filetree_toroot(Filetree* ft){
    while(ft->parent)
        ft = ft->parent;
    return ft;
}

void filetree_append(Filetree* ft, const char* text){
    if(ft->type != FT_FILE) return;
    string_append(ft->contents, text);
}


Filetree* filetree_search_file(Filetree* ft, char* path){
    for(char* tmp = path; !isspace(*tmp) && *tmp && ft; tmp++){
        if(*tmp == '/'){
            if(isspace(tmp[1]) || !tmp[1]) return NULL;
            *tmp = '\0';
            ft = filetree_cd(ft, path);
            path = tmp+1;
        }
    }
    if(ft == NULL) return NULL;
    return filetree_open(ft, path);
}

void filetree_build(Filetree* ft){
    for(int i=0; i<ft->next; i++){
        if(ft->children[i]->type == FT_FOLDER){
            if(mkdir(ft->children[i]->name, 0777)){
                fprintf(stderr, "Failed creating folder %s.\nExiting program...\n.", ft->children[i]->name);
                exit(3);
            }
            chdir(ft->children[i]->name);
            filetree_build(ft->children[i]);
            chdir("..");
        }
        else if(ft->children[i]->type == FT_FILE){
            if( access( ft->children[i]->name, F_OK ) != -1 ){
                fprintf(stderr, "File %s exists.\nExiting program...\n", ft->children[i]->name);
                exit(1);
            }
            FILE* file = fopen(ft->children[i]->name, "w");
            if(!file){
                fprintf(stderr, "Failed opening %s.\nExiting program...\n", ft->children[i]->name);
                exit(1);
            }
            fprintf(file, "%s", string_get(ft->children[i]->contents));
            fflush(file);
            if(fclose(file)){
                fprintf(stderr, "Failed writing to file %s.\nExiting program...\n", ft->children[i]->name);
                exit(1);
            }
        }
    }
}

void filetree_free(Filetree* ft){
    if(ft){
        free(ft->name);
        string_free(ft->contents);
        for(int i=0; i<ft->next; i++)
            filetree_free(ft->children[i]);
        free(ft->children);
    }
    free(ft);
}


void filetree_print_(Filetree* ft, int depth){
    for(int i=0; i<depth; i++) printf("%c", '\t');
    printf("%s [%s] {%s}\n"
        , ft->type == FT_FILE ? "FILE" : "FOLDER"
        , ft->name
        , ft->type == FT_FILE ? string_get(ft->contents) : "");
    for(int i=0; i<ft->next; i++)
        filetree_print_(ft->children[i], depth+1);
}

void filetree_print(Filetree* ft){
    filetree_print_(ft, 0);
}