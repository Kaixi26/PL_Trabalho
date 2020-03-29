#include "stringbuilder.h"

Stringbuilder* string_init(){
    Stringbuilder* tmp = malloc(sizeof(Stringbuilder));
    tmp->next = 0;
    tmp->size = 1;
    tmp->str = calloc(1, sizeof(char));
    return tmp;
}
void string_expand(Stringbuilder* sb){
    sb->size *= 2;
    sb->str = realloc(sb->str, sb->size * sizeof(char));
}

void string_append(Stringbuilder* sb, const char* source){
    for(int i=0; source[i]; i++, sb->next++){
        if(sb->next >= sb->size-1)
            string_expand(sb);
        sb->str[sb->next] = source[i];
    }
    sb->str[sb->next] = '\0';
}

void string_appendc(Stringbuilder* sb, const char c){
    if(sb->next >= sb->size-1)
        string_expand(sb);
    sb->str[sb->next++] = c;
    sb->str[sb->next] = '\0';
}

const char* string_get(Stringbuilder* sb){
    return sb->str;
}

void string_free(Stringbuilder* sb){
    if(sb)
        free(sb->str);
    free(sb);
}