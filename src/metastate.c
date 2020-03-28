#include "metastate.h"

void metastate_getpairind(char* str, int *key_i, int *val_i){
    *key_i = -1;
    *val_i = -1;
    int i;
    for(i=0; str[i]; i++){
        if(isspace(str[i])) str[i] = '\0';
        else if(str[i] == ':') {
            str[i++] = '\0';
            break;
        }
        else if(*key_i == -1) *key_i = i;
    }
    for(; str[i]; i++){
        if(isspace(str[i])) str[i] = '\0';
        else if(*val_i == -1) *val_i = i;
    }
}