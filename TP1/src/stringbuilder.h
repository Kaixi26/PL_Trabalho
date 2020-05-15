#ifndef STRING_BUILDER_H
#define STRING_BUILDER_H

#include <stdlib.h>

typedef struct {
    int next;
    int size;
    char* str;
} Stringbuilder;

Stringbuilder* string_init();
void string_append(Stringbuilder*, const char*);
void string_appendc(Stringbuilder*, const char);
const char* string_get(Stringbuilder*);
void string_free(Stringbuilder*);

#endif