#include <stdio.h>
#include <stdlib.h>
#include "tomlValue.h"
#include <math.h>
#include <string.h>

t_tomlv t_tomlv_fromInt(int v){
    return (t_tomlv){
        .val.vint = v,
        .code = TOMLVALUE_INT
    };
}

t_tomlv t_tomlv_fromDouble(double v){
    return (t_tomlv){
        .val.vdouble = v,
        .code = TOMLVALUE_DOUBLE
    };
}

t_tomlv t_tomlv_fromBool(int v){
    return (t_tomlv){
        .val.vbool = v,
        .code = TOMLVALUE_BOOL
    };
}

t_tomlv t_tomlv_fromStr(char* v){
    return (t_tomlv){
        .val.vstr = v,
        .code = TOMLVALUE_STR
    };
}

t_tomlv t_tomlv_fromArr(t_toml_arr* v){
    return (t_tomlv){
        .val.varr = v,
        .code = TOMLVALUE_ARR
    };
}

t_toml_arr* t_toml_arr_init(){
    return calloc(1, sizeof(t_toml_arr));
}

void t_toml_arr_append(t_toml_arr* arr, t_tomlv val){
    if(arr->next >= arr->size){
        arr->size = arr->size ? 2*arr->size : 1;
        arr->vals = realloc(arr->vals, arr->size * sizeof(t_tomlv));
    }
    arr->vals[arr->next++] = val;
}

void t_tomlv_jsonPrint(t_tomlv v){
    switch(v.code){
        case TOMLVALUE_INT:
            printf("%d", v.val.vint);
            break;
        case TOMLVALUE_DOUBLE:
            if(isnan(v.val.vdouble)) printf("\"nan\"");
            else if(v.val.vdouble == -INFINITY) printf("\"-inf\"");
            else if(v.val.vdouble == +INFINITY) printf("\"+inf\"");
            else printf("%f", v.val.vdouble);
            break;
        case TOMLVALUE_BOOL:
            printf("%s", v.val.vbool ? "true" : "false");
            break;
        case TOMLVALUE_STR:
            printf("\"%s\"", v.val.vstr);
            break;
        case TOMLVALUE_ARR:
            printf("[ ");
            int i;
            for(i=0; i < v.val.varr->next-1; i++){
                t_tomlv_jsonPrint(v.val.varr->vals[i]);
                printf(", ");
            }
            if(i != 0 || v.val.varr->next == 1){
                t_tomlv_jsonPrint(v.val.varr->vals[i]);
                printf(" ");
            }
            printf("]");
            break;
    }
}


t_toml_keyvalue* t_toml_keyvalue_init(char* key, t_tomlv value){
    t_toml_keyvalue* ret = calloc(1, sizeof(t_toml_keyvalue));
    ret->key = key;
    ret->value = value;
    return ret;
}

void t_toml_keyvalue_jsonPrint(t_toml_keyvalue* kv){
    printf("%s:", kv->key);
    t_tomlv_jsonPrint(kv->value);
}

t_toml_keyvalues* t_toml_keyvalues_init(){
    return calloc(1, sizeof(t_toml_keyvalues));
}

void t_toml_keyvalues_insert(t_toml_keyvalues* kvs, t_toml_keyvalue* kv){
    if(kvs->next >= kvs->size){
        kvs->size = kvs->size ? 2*kvs->size : 1;
        kvs->kvs = realloc(kvs->kvs, kvs->size * sizeof(t_toml_keyvalue*));
    }
    kvs->kvs[kvs->next++] = kv;
}

void t_toml_keyvalues_prepend(t_toml_keyvalues* kvs, char* pre){
    int size = strlen(pre);
    for(int i=0; i < kvs->next; i++){
        int vsize = strlen(kvs->kvs[i]->key);
        char* tmp = calloc(size + vsize + 2, sizeof(char));
        strcpy(tmp, pre);
        tmp[size] = '.';
        strcpy(tmp + size + 1, kvs->kvs[i]->key);
        free(kvs->kvs[i]->key);
        kvs->kvs[i]->key = tmp;
    }
}

void t_toml_keyvalues_print(t_toml_keyvalues* kvs){
    for(int i=0; i < kvs->next; i++){
        t_toml_keyvalue_jsonPrint(kvs->kvs[i]);
        printf("\n");
    }
}

t_toml_keyvalues* t_toml_keyvalues_merge(t_toml_keyvalues* kvs, t_toml_keyvalues* kvs2){
    for(int i=0; i < kvs2->next; i++)
        t_toml_keyvalues_insert(kvs, kvs2->kvs[i]);
    free(kvs2->kvs);
    free(kvs2);
    return kvs;
}
