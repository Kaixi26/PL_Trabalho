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

/* Allocates memory needed for structure and returns pointer to it */
Metadata* metadata_init();
/* Fetches the value associated with a key */
const char* metadata_get(Metadata*, const char* key);
/* Inserts a key value pair into the structure */
void metadata_put(Metadata*, const char* key, const char* value);
/* Prints the structure in a humanly readable way */
void metadata_print(Metadata*);
/* substitutes all the ocurring {%key%} with the corresponding value */
Stringbuilder* metadata_substitute(Metadata* m, char* str);
/* Deallocates the memory for the structure and all that depends on it */
void metadata_free(Metadata*);