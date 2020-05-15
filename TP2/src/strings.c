#include "strings.h"

void strrmc(char* str, char c){
    int j=0;
    for(int i=0; str[i]; i++){
        str[j] = str[i];
        if(str[i] != c) j++;
    }
    str[j]=0;
}