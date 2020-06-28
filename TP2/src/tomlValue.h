#ifndef TOMLVALUE
#define TOMLVALUE

#define TOMLVALUE_INT       0
#define TOMLVALUE_DOUBLE    1
#define TOMLVALUE_BOOL      2
#define TOMLVALUE_STR       3
#define TOMLVALUE_ARR       4

typedef struct t_toml_arr t_toml_arr;

typedef struct t_tomlv {
    union{
        int vint;
        double vdouble;
        int vbool;
        char* vstr;
        t_toml_arr* varr;
    } val;
    char code; /* representa o tipo de dados guardado */
} t_tomlv;

struct t_toml_arr {
    int next;
    int size;
    t_tomlv* vals;
};

typedef struct t_toml_keyvalue {
    char* key;
    t_tomlv value;
} t_toml_keyvalue;

typedef struct t_toml_keyvalues {
    int next;
    int size;
    t_toml_keyvalue** kvs;
} t_toml_keyvalues;


t_tomlv t_tomlv_fromInt(int);
t_tomlv t_tomlv_fromDouble(double);
t_tomlv t_tomlv_fromBool(int);
t_tomlv t_tomlv_fromStr(char*);
t_tomlv t_tomlv_fromArr(t_toml_arr*);

t_toml_arr* t_toml_arr_init();
void t_toml_arr_append(t_toml_arr* arr, t_tomlv val);
t_toml_keyvalue* t_toml_keyvalue_init(char* key, t_tomlv value);

t_toml_keyvalues* t_toml_keyvalues_init();
void t_toml_keyvalues_insert(t_toml_keyvalues*, t_toml_keyvalue*);
void t_toml_keyvalues_prepend(t_toml_keyvalues* kvs, char* pre);

/* merges the two groups into one, the arguments are freed and should not be used after the function call */
t_toml_keyvalues* t_toml_keyvalues_merge(t_toml_keyvalues*, t_toml_keyvalues*);
void t_toml_keyvalues_print(t_toml_keyvalues* kvs);


void t_tomlv_jsonPrint(t_tomlv);
void t_toml_keyvalue_jsonPrint(t_toml_keyvalue* kv);


#endif