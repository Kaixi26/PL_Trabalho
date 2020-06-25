#include "valueTree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

treeChildren* treeChildren_init(){
    return calloc(1, sizeof(treeChildren));
}

void treeChildren_insert(treeChildren* children, valueTree* child){
    if(children->next >= children->size){
        children->size = children->size ? 2*children->size : 1;
        children->child = realloc(children->child, children->size * sizeof(valueTree*));
    }
    children->child[children->next++] = child;
}

valueTree* valueTree_init_leaf(char* key, t_tomlv value){
    valueTree* ret = calloc(1, sizeof(valueTree));
    ret->key = key;
    ret->isLeaf = 1;
    ret->value.value = value;
    return ret;
}

valueTree* valueTree_init_node(char* key){
    valueTree* ret = calloc(1, sizeof(valueTree));
    ret->key = key;
    ret->value.children = treeChildren_init();
    ret->isLeaf = 0;
    return ret;
}

int valueTree_node_insert(valueTree*, char*, t_tomlv);

int valueTree_node_insertNode(valueTree* vt, char* key, char* nextKey, t_tomlv value){
    for(int i=0; i < vt->value.children->next; i++){
        if(!strcmp(key, vt->value.children->child[i]->key)){
            if(vt->value.children->child[i]->isLeaf){
                return 3;
            } else
                return valueTree_node_insert(vt->value.children->child[i], nextKey, value);
        }
    }
    valueTree* tmp = valueTree_init_node(strdup(key));
    int ret = valueTree_node_insert(tmp, nextKey, value);
    treeChildren_insert(vt->value.children, tmp);
    return ret;
}

int valueTree_node_insert(valueTree* vt, char* key, t_tomlv value){
    if(vt->isLeaf) return 1;
    char* nextKey = strrchr(key, '.');
    if(nextKey){
        *nextKey = 0;
        int ret = valueTree_node_insertNode(vt, key, nextKey+1, value);
        *nextKey = '.';
        return ret;
    } else {
        for(int i=0; i < vt->value.children->next; i++)
            if(!strcmp(key, vt->value.children->child[i]->key)) return 2;
        treeChildren_insert(vt->value.children , valueTree_init_leaf(key, value));
    }
    return 0;
}

valueTree* valueTree_fromKeyValues(t_toml_keyvalues* kvs){
    valueTree* ret = valueTree_init_node(NULL);
    for(int i=0; i < kvs->next; i++)
        valueTree_node_insert(ret, kvs->kvs[i]->key, kvs->kvs[i]->value);

    return ret;
}

void valueTree_printAux(valueTree* vt, int depth){
    for(int i=0; i<depth; i++)
        printf("\t");
    if(!vt->isLeaf){
        printf("%s\n", vt->key ? vt->key : "root");
        for(int i=0; i<vt->value.children->next; i++)
            valueTree_printAux(vt->value.children->child[i], depth+1);
    } else {
        printf("%s : ", vt->key);
        t_tomlv_jsonPrint(vt->value.value);
        printf("\n");
    }
}

void valueTree_print(valueTree* vt){
    valueTree_printAux(vt, 0);
}