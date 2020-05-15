#include "metadata.h"

Metadata* metadata_init(){
    Metadata* m = malloc(sizeof(Metadata));
    m->next = 0;
    m->size = 1;
    m->keys = calloc(sizeof(const char*), m->size);
    m->vals = calloc(sizeof(const char*), m->size);
    return m;
}

void metadata_expand(Metadata* m){
    m->size *= 2;
    m->keys = realloc(m->keys, m->size * sizeof(const char*));
    m->vals = realloc(m->vals, m->size * sizeof(const char*));
}

void metadata_put(Metadata* m, const char* key, const char* value){
    if(m->next >= m->size)
        metadata_expand(m);
    m->keys[m->next] = strdup(key);
    m->vals[m->next] = strdup(value);
    m->next++;
}

const char* metadata_get(Metadata* m, const char* key){
    for(int i=0; i<m->next; i++)
        if(!strcmp(m->keys[i], key))
            return m->vals[i];
    return NULL;
}

void metadata_print(Metadata* m){
    printf("[ ");
    for(int i=0; i<m->next; i++)
        printf("(%s,%s) ", m->keys[i], m->vals[i]);
    printf("]\n");
}

char* strmatch(char* str, char* delim){
    for(int i=0; str[i]; i++)
        for(int j=0; str[i+j]; j++){
            if(delim[j] == '\0') return str+i;
            if(str[i+j] != delim[j]) break;
        }
    return NULL;
}

Stringbuilder* metadata_substitute(Metadata* m, char* str){
    Stringbuilder* sb = string_init();
    int state = 0;
    for(char* prev = str; prev; state = !state){
        char* curr = strmatch(prev, state ? "%}" : "{%");
        if(curr){
            *curr = 0;
            curr += 2;
        }
        const char* tmp = state ? metadata_get(m, prev) : prev;
        if(!tmp) goto ERR;
        string_append(sb, tmp);
        prev = curr;
    }
    return sb;
ERR:
    string_free(sb);
    return NULL;
}

void metadata_free(Metadata* m){
    if(m){
        for(int i=0; i<m->next; i++){
            free(m->keys[i]);
            free(m->vals[i]);
        }
        free(m->keys);
        free(m->vals);
    }
    free(m);
}