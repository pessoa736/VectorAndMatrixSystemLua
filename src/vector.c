/*
 * VMSL — Vector Module (C implementation)
 * Lua C extension for N-dimensional vector operations.
 *
 * Provides the same API as the pure-Lua version:
 *   local V = require("vectors")
 *   local v = V.CreateVector(1, 2, 3)
 *
 * MIT License — see project root.
 */

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define VECTOR_MT "VMSL.Vector"

/* ── data structure ──────────────────────────────────────────────── */

typedef struct {
    int dim;
    double pts[];   /* C99 flexible array member */
} Vector;

/* ── helpers ─────────────────────────────────────────────────────── */

static Vector *vec_new(lua_State *L, int dim) {
    Vector *v = (Vector *)lua_newuserdata(L, sizeof(Vector) + dim * sizeof(double));
    v->dim = dim;
    memset(v->pts, 0, dim * sizeof(double));
    luaL_setmetatable(L, VECTOR_MT);
    return v;
}

static Vector *vec_check(lua_State *L, int idx) {
    return (Vector *)luaL_checkudata(L, idx, VECTOR_MT);
}

static Vector *vec_test(lua_State *L, int idx) {
    return (Vector *)luaL_testudata(L, idx, VECTOR_MT);
}

/* ── determinant helper (for generalised cross product) ──────────── */

static double det_nxn(const double *data, int n) {
    if (n == 1) return data[0];
    if (n == 2) return data[0] * data[3] - data[1] * data[2];

    double result = 0;
    double *sub = (double *)malloc((n - 1) * (n - 1) * sizeof(double));

    for (int j = 0; j < n; j++) {
        int idx = 0;
        for (int r = 1; r < n; r++) {
            for (int c = 0; c < n; c++) {
                if (c != j) sub[idx++] = data[r * n + c];
            }
        }
        double sign = (j % 2 == 0) ? 1.0 : -1.0;
        result += sign * data[j] * det_nxn(sub, n - 1);
    }

    free(sub);
    return result;
}

/* ── module-level functions ──────────────────────────────────────── */

static int vec_CreateVector(lua_State *L) {
    int n = lua_gettop(L);
    if (n <= 0) return luaL_error(L, "there is no dimensionless vector");

    for (int i = 1; i <= n; i++) {
        if (!lua_isnumber(L, i))
            return luaL_error(L, "argument #%d is not a number", i);
    }

    Vector *v = vec_new(L, n);
    for (int i = 0; i < n; i++)
        v->pts[i] = lua_tonumber(L, i + 1);
    return 1;
}

static int vec_IsVector(lua_State *L) {
    if (vec_test(L, 1)) {
        lua_pushboolean(L, 1);
        lua_pushliteral(L, "vector");
    } else {
        lua_pushboolean(L, 0);
        lua_pushstring(L, luaL_typename(L, 1));
    }
    return 2;
}

static int vec_CreateConstVector(lua_State *L) {
    int dim = (int)luaL_checkinteger(L, 1);
    double val = luaL_checknumber(L, 2);
    if (dim < 1) return luaL_error(L, "dimension must be >= 1");

    Vector *v = vec_new(L, dim);
    for (int i = 0; i < dim; i++) v->pts[i] = val;
    return 1;
}

static int vec_CreateVectorZero(lua_State *L) {
    int dim = (int)luaL_checkinteger(L, 1);
    if (dim < 1) return luaL_error(L, "dimension must be >= 1");
    vec_new(L, dim); /* already zero-initialised */
    return 1;
}

static int vec_CreateVectorOne(lua_State *L) {
    int dim = (int)luaL_checkinteger(L, 1);
    if (dim < 1) return luaL_error(L, "dimension must be >= 1");
    Vector *v = vec_new(L, dim);
    for (int i = 0; i < dim; i++) v->pts[i] = 1.0;
    return 1;
}

/* ── methods ─────────────────────────────────────────────────────── */

static int vec_Dot(lua_State *L) {
    /* v1:Dot(v2)  → dot product
       v1:Dot(s)   → scalar multiplication
       called via __mul too: number * vector */
    if (lua_isnumber(L, 1)) {
        double s = lua_tonumber(L, 1);
        Vector *v = vec_check(L, 2);
        Vector *r = vec_new(L, v->dim);
        for (int i = 0; i < v->dim; i++) r->pts[i] = v->pts[i] * s;
        return 1;
    }

    Vector *v1 = vec_check(L, 1);

    if (lua_isnumber(L, 2)) {
        double s = lua_tonumber(L, 2);
        Vector *r = vec_new(L, v1->dim);
        for (int i = 0; i < v1->dim; i++) r->pts[i] = v1->pts[i] * s;
        return 1;
    }

    Vector *v2 = vec_check(L, 2);
    if (v1->dim != v2->dim)
        return luaL_error(L, "vectors are not equipollent");

    double d = 0;
    for (int i = 0; i < v1->dim; i++) d += v1->pts[i] * v2->pts[i];
    lua_pushnumber(L, d);
    return 1;
}

static int vec_Cross(lua_State *L) {
    int nargs = lua_gettop(L);
    if (nargs < 1) return luaL_error(L, "expected at least one vector");

    Vector *v1 = vec_check(L, 1);
    int n = v1->dim;

    /* 2D perpendicular */
    if (n == 2 && nargs == 1) {
        Vector *r = vec_new(L, 2);
        r->pts[0] = -v1->pts[1];
        r->pts[1] =  v1->pts[0];
        return 1;
    }

    /* 3D standard cross */
    if (n == 3 && nargs == 2) {
        Vector *v2 = vec_check(L, 2);
        if (v2->dim != 3) return luaL_error(L, "vectors are not equipollent");
        Vector *r = vec_new(L, 3);
        r->pts[0] = v1->pts[1] * v2->pts[2] - v1->pts[2] * v2->pts[1];
        r->pts[1] = v1->pts[2] * v2->pts[0] - v1->pts[0] * v2->pts[2];
        r->pts[2] = v1->pts[0] * v2->pts[1] - v1->pts[1] * v2->pts[0];
        return 1;
    }

    /* General nD: need exactly n-1 vectors */
    if (nargs != n - 1)
        return luaL_error(L,
            "for cross product in R^%d you need %d vectors", n, n - 1);

    for (int i = 2; i <= nargs; i++) {
        Vector *vi = vec_check(L, i);
        if (vi->dim != n)
            return luaL_error(L, "vectors are not equipollent");
    }

    /* Build (n-1) × n matrix from input vectors (each row = one vector) */
    double *mat   = (double *)malloc((n - 1) * n * sizeof(double));
    double *minor = (double *)malloc((n - 1) * (n - 1) * sizeof(double));

    for (int i = 0; i < n - 1; i++) {
        Vector *vi = (Vector *)lua_touserdata(L, i + 1);
        memcpy(mat + i * n, vi->pts, n * sizeof(double));
    }

    Vector *result = vec_new(L, n);

    for (int col = 0; col < n; col++) {
        int idx = 0;
        for (int r = 0; r < n - 1; r++) {
            for (int c = 0; c < n; c++) {
                if (c != col) minor[idx++] = mat[r * n + c];
            }
        }
        double sign = (col % 2 == 0) ? 1.0 : -1.0;
        result->pts[col] = sign * det_nxn(minor, n - 1);
    }

    free(minor);
    free(mat);
    return 1;
}

static int vec_checkEquipollence(lua_State *L) {
    Vector *v1 = vec_check(L, 1);
    Vector *v2 = vec_check(L, 2);
    lua_pushboolean(L, v1->dim == v2->dim);
    lua_pushinteger(L, v1->dim);
    return 2;
}

static int vec_map(lua_State *L) {
    Vector *v = vec_check(L, 1);
    luaL_checktype(L, 2, LUA_TFUNCTION);

    Vector *r = vec_new(L, v->dim);

    for (int i = 0; i < v->dim; i++) {
        lua_pushvalue(L, 2);              /* function                */
        lua_pushinteger(L, i + 1);        /* dim (1-based)           */
        lua_pushnumber(L, v->pts[i]);     /* current value           */
        lua_call(L, 2, 1);

        if (lua_isnumber(L, -1))
            r->pts[i] = lua_tonumber(L, -1);
        else
            r->pts[i] = v->pts[i];
        lua_pop(L, 1);
    }

    return 1;   /* result already on stack */
}

static int vec_projection(lua_State *L) {
    Vector *v1 = vec_check(L, 1);
    Vector *v2 = vec_check(L, 2);
    if (v1->dim != v2->dim)
        return luaL_error(L, "vectors are not equipollent");

    double dot_v2_v1 = 0, dot_v1_v1 = 0;
    for (int i = 0; i < v1->dim; i++) {
        dot_v2_v1 += v2->pts[i] * v1->pts[i];
        dot_v1_v1 += v1->pts[i] * v1->pts[i];
    }

    double scalar = dot_v2_v1 / dot_v1_v1;
    Vector *r = vec_new(L, v1->dim);
    for (int i = 0; i < v1->dim; i++)
        r->pts[i] = scalar * v1->pts[i];
    return 1;
}

/* ── Circumference ───────────────────────────────────────────────── */

static int circ_getRadius(lua_State *L) {
    Vector *v1 = vec_check(L, 1);
    Vector *v2 = vec_check(L, 2);
    if (v1->dim != v2->dim)
        return luaL_error(L, "vectors are not equipollent");

    double sum = 0;
    for (int i = 0; i < v1->dim; i++) {
        double d = v1->pts[i] - v2->pts[i];
        sum += d * d;
    }
    lua_pushnumber(L, sum);
    return 1;
}

/* __call on Circumference table: first arg is the table itself */
static int circ_call(lua_State *L) {
    Vector *v1 = vec_check(L, 2);
    Vector *v2 = vec_check(L, 3);
    if (v1->dim != v2->dim)
        return luaL_error(L, "vectors are not equipollent");

    double sum = 0;
    for (int i = 0; i < v1->dim; i++) {
        double d = v1->pts[i] - v2->pts[i];
        sum += d * d;
    }
    lua_pushnumber(L, sum);
    return 1;
}

static int circ_getPerimeter(lua_State *L) {
    Vector *v1 = vec_check(L, 1);
    Vector *v2 = vec_check(L, 2);
    if (v1->dim != v2->dim)
        return luaL_error(L, "vectors are not equipollent");

    double sum = 0;
    for (int i = 0; i < v1->dim; i++) {
        double d = v1->pts[i] - v2->pts[i];
        sum += d * d;
    }
    lua_pushnumber(L, 2.0 * sum * M_PI);
    return 1;
}

/* ── metamethods ─────────────────────────────────────────────────── */

static int vec_add(lua_State *L) {
    Vector *v1 = vec_check(L, 1);
    Vector *v2 = vec_check(L, 2);
    if (v1->dim != v2->dim)
        return luaL_error(L, "vectors are not equipollent");

    Vector *r = vec_new(L, v1->dim);
    for (int i = 0; i < v1->dim; i++)
        r->pts[i] = v1->pts[i] + v2->pts[i];
    return 1;
}

static int vec_sub(lua_State *L) {
    Vector *v1 = vec_check(L, 1);
    Vector *v2 = vec_check(L, 2);
    if (v1->dim != v2->dim)
        return luaL_error(L, "vectors are not equipollent");

    Vector *r = vec_new(L, v1->dim);
    for (int i = 0; i < v1->dim; i++)
        r->pts[i] = v1->pts[i] - v2->pts[i];
    return 1;
}

static int vec_unm(lua_State *L) {
    Vector *v = vec_check(L, 1);
    Vector *r = vec_new(L, v->dim);
    for (int i = 0; i < v->dim; i++) r->pts[i] = -v->pts[i];
    return 1;
}

static int vec_mul(lua_State *L) {
    Vector *v1 = vec_test(L, 1);
    Vector *v2 = vec_test(L, 2);

    if (v1 && v2) {
        /* dot product */
        if (v1->dim != v2->dim)
            return luaL_error(L, "vectors are not equipollent");
        double d = 0;
        for (int i = 0; i < v1->dim; i++) d += v1->pts[i] * v2->pts[i];
        lua_pushnumber(L, d);
        return 1;
    }

    if (v1 && lua_isnumber(L, 2)) {
        double s = lua_tonumber(L, 2);
        Vector *r = vec_new(L, v1->dim);
        for (int i = 0; i < v1->dim; i++) r->pts[i] = v1->pts[i] * s;
        return 1;
    }

    if (v2 && lua_isnumber(L, 1)) {
        double s = lua_tonumber(L, 1);
        Vector *r = vec_new(L, v2->dim);
        for (int i = 0; i < v2->dim; i++) r->pts[i] = v2->pts[i] * s;
        return 1;
    }

    return luaL_error(L, "unsupported operand types for multiplication");
}

static int vec_len(lua_State *L) {
    Vector *v = vec_check(L, 1);
    lua_pushinteger(L, v->dim);
    return 1;
}

static int vec_tostring(lua_State *L) {
    Vector *v = vec_check(L, 1);
    luaL_Buffer b;
    luaL_buffinit(L, &b);

    char buf[64];
    snprintf(buf, sizeof(buf), "Vector%d:{", v->dim);
    luaL_addstring(&b, buf);

    for (int i = 0; i < v->dim; i++) {
        snprintf(buf, sizeof(buf), " %.14g", v->pts[i]);
        luaL_addstring(&b, buf);
        if (i < v->dim - 1)
            luaL_addstring(&b, ",");
        else
            luaL_addchar(&b, ' ');
    }

    luaL_addchar(&b, '}');
    luaL_pushresult(&b);
    return 1;
}

static int vec_concat(lua_State *L) {
    luaL_tolstring(L, 1, NULL);
    luaL_tolstring(L, 2, NULL);
    lua_concat(L, 2);
    return 1;
}

static int vec_index(lua_State *L) {
    Vector *v = vec_check(L, 1);

    /* numeric index → component */
    if (lua_type(L, 2) == LUA_TNUMBER) {
        int k = (int)lua_tointeger(L, 2);
        if (k >= 1 && k <= v->dim) {
            lua_pushnumber(L, v->pts[k - 1]);
            return 1;
        }
        lua_pushnil(L);
        return 1;
    }

    /* string key → property or method */
    if (lua_type(L, 2) == LUA_TSTRING) {
        const char *key = lua_tostring(L, 2);

        if (strcmp(key, "Dimensions") == 0) {
            lua_pushinteger(L, v->dim);
            return 1;
        }
        if (strcmp(key, "type") == 0) {
            lua_pushliteral(L, "vector");
            return 1;
        }
        if (strcmp(key, "points") == 0) {
            lua_createtable(L, v->dim, 0);
            for (int i = 0; i < v->dim; i++) {
                lua_pushnumber(L, v->pts[i]);
                lua_rawseti(L, -2, i + 1);
            }
            return 1;
        }

        /* look up in metatable (methods) */
        luaL_getmetatable(L, VECTOR_MT);
        lua_pushvalue(L, 2);
        lua_rawget(L, -2);
        return 1;
    }

    lua_pushnil(L);
    return 1;
}

static int vec_newindex(lua_State *L) {
    Vector *v = vec_check(L, 1);

    if (lua_type(L, 2) == LUA_TNUMBER) {
        int k = (int)lua_tointeger(L, 2);
        if (k >= 1 && k <= v->dim)
            v->pts[k - 1] = luaL_checknumber(L, 3);
    }
    return 0;
}

/* ── registration tables ─────────────────────────────────────────── */

static const luaL_Reg vec_methods[] = {
    {"Dot",                  vec_Dot},
    {"Cross",                vec_Cross},
    {"CrossProduct_2D_or_3D",vec_Cross},   /* same impl handles all dims */
    {"projection",           vec_projection},
    {"map",                  vec_map},
    {"checkEquipollence",    vec_checkEquipollence},
    {NULL, NULL}
};

static const luaL_Reg vec_meta[] = {
    {"__add",      vec_add},
    {"__sub",      vec_sub},
    {"__mul",      vec_mul},
    {"__unm",      vec_unm},
    {"__len",      vec_len},
    {"__tostring", vec_tostring},
    {"__concat",   vec_concat},
    {"__index",    vec_index},
    {"__newindex",  vec_newindex},
    {NULL, NULL}
};

static const luaL_Reg vec_module[] = {
    {"CreateVector",      vec_CreateVector},
    {"IsVector",          vec_IsVector},
    {"CreateConstVector", vec_CreateConstVector},
    {"CreateVectorZero",  vec_CreateVectorZero},
    {"CreateVectorOne",   vec_CreateVectorOne},
    {NULL, NULL}
};

/* ── module entry point ──────────────────────────────────────────── */

int luaopen_vectors(lua_State *L) {
    /* metatable */
    luaL_newmetatable(L, VECTOR_MT);
    luaL_setfuncs(L, vec_meta, 0);
    luaL_setfuncs(L, vec_methods, 0);   /* found via __index fallback */
    lua_pop(L, 1);

    /* module table */
    luaL_newlib(L, vec_module);

    /* Circumference sub-table */
    lua_newtable(L);
    lua_pushcfunction(L, circ_getRadius);
    lua_setfield(L, -2, "getRadius");
    lua_pushcfunction(L, circ_getPerimeter);
    lua_setfield(L, -2, "getPerimeter");

    /* make Circumference callable → defaults to getRadius */
    lua_newtable(L);                          /* metatable */
    lua_pushcfunction(L, circ_call);
    lua_setfield(L, -2, "__call");
    lua_setmetatable(L, -2);

    lua_setfield(L, -2, "Circumference");

    return 1;
}
