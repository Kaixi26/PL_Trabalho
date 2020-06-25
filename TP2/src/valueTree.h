#ifndef VALUETREE_H
#define VALUETREE_H
#include "tomlValue.h"

typedef struct valueTree valueTree;
typedef struct treeChildren treeChildren;

struct treeChildren {
    int next;
    int size;
    valueTree** child;
};

struct valueTree {
    char* key;
    union {
        t_tomlv value;
        treeChildren* children;
    } value;
    char isLeaf;
};

valueTree* valueTree_fromKeyValues(t_toml_keyvalues* kvs);

void valueTree_print(valueTree*);

#endif