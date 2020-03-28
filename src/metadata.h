#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stringbuilder.h"

typedef struct {
    int next;
    int size;
    char** keys;
    char** vals;
} Metadata;

Metadata* metadata_init();
const char* metadata_get(Metadata*, const char* key);
void metadata_put(Metadata*, const char* key, const char* value);
void metadata_print(Metadata*);
Stringbuilder* metadata_substitute(Metadata* m, char* str);
void metadata_free(Metadata*);