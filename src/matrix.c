/*
 * VMSL — Matrix Module (C implementation)
 * Lua C extension for M×N matrix operations.
 *
 * Provides the same API as the pure-Lua version:
 *   local M = require("matrix")
 *   local A = M.CreateMatrix(2, 2).data(1, 2, 3, 4)
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

#define MATRIX_MT "VMSL.Matrix"

/* ── data structure ──────────────────────────────────────────────── */

typedef struct {
    int nrows;
    int ncols;
    double data[];  /* C99 flexible array member, row-major */
} Matrix;

/* ── helpers ─────────────────────────────────────────────────────── */

static Matrix *mat_new(lua_State *L, int nr, int nc) {
    int n = nr * nc;
    Matrix *m = (Matrix *)lua_newuserdata(L, sizeof(Matrix) + n * sizeof(double));
    m->nrows = nr;
    m->ncols = nc;
    memset(m->data, 0, n * sizeof(double));
    luaL_setmetatable(L, MATRIX_MT);
    return m;
}

static Matrix *mat_check(lua_State *L, int idx) {
    return (Matrix *)luaL_checkudata(L, idx, MATRIX_MT);
}

static Matrix *mat_test(lua_State *L, int idx) {
    return (Matrix *)luaL_testudata(L, idx, MATRIX_MT);
}

/* positive modulo (Lua-style: always non-negative) */
static int mod_pos(int a, int m) {
    return ((a % m) + m) % m;
}

/* Extract i or j from a table key at stack position `tidx`.
   Tries key[arrayIdx] first, then key[fieldName]. */
static int mat_get_ij(lua_State *L, int tidx, int arrayIdx, const char *fieldName) {
    lua_rawgeti(L, tidx, arrayIdx);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_getfield(L, tidx, fieldName);
    }
    int v = (int)luaL_checkinteger(L, -1);
    lua_pop(L, 1);
    return v;
}

/* ── determinant (cofactor expansion, flat row-major) ────────────── */

static double det_flat(const double *data, int n) {
    if (n == 1) return data[0];
    if (n == 2) return data[0] * data[3] - data[1] * data[2];
    if (n == 3) {
        return data[0] * (data[4] * data[8] - data[5] * data[7])
             + data[1] * (data[5] * data[6] - data[3] * data[8])
             + data[2] * (data[3] * data[7] - data[4] * data[6]);
    }

    double det = 0;
    double *sub = (double *)malloc((n - 1) * (n - 1) * sizeof(double));

    for (int j = 0; j < n; j++) {
        int idx = 0;
        for (int r = 1; r < n; r++) {
            for (int c = 0; c < n; c++) {
                if (c != j) sub[idx++] = data[r * n + c];
            }
        }
        double sign = (j % 2 == 0) ? 1.0 : -1.0;
        det += sign * data[j] * det_flat(sub, n - 1);
    }

    free(sub);
    return det;
}

/* ── builder: .data(...) closure ─────────────────────────────────── */

static int mat_data_fill(lua_State *L) {
    Matrix *m = (Matrix *)lua_touserdata(L, lua_upvalueindex(1));
    int n = m->nrows * m->ncols;
    int nargs = lua_gettop(L);

    for (int i = 0; i < n && i < nargs; i++)
        m->data[i] = luaL_checknumber(L, i + 1);

    /* return the matrix userdata */
    lua_pushvalue(L, lua_upvalueindex(1));
    return 1;
}

/* ── module-level functions ──────────────────────────────────────── */

static int mat_CreateMatrix(lua_State *L) {
    int nr = (int)luaL_checkinteger(L, 1);
    int nc = (int)luaL_checkinteger(L, 2);
    if (nr + nc <= 1)
        return luaL_error(L, "there are not matrix 0x0");

    mat_new(L, nr, nc);
    return 1;
}

static int mat_CreateColumnMatrix(lua_State *L) {
    int n = lua_gettop(L);
    if (n == 0) return luaL_error(L, "expected at least one value");

    Matrix *m = mat_new(L, 1, n);
    for (int i = 0; i < n; i++)
        m->data[i] = luaL_checknumber(L, i + 1);
    return 1;
}

static int mat_CreateRowMatrix(lua_State *L) {
    int n = lua_gettop(L);
    if (n == 0) return luaL_error(L, "expected at least one value");

    Matrix *m = mat_new(L, n, 1);
    for (int i = 0; i < n; i++)
        m->data[i] = luaL_checknumber(L, i + 1);
    return 1;
}

static int mat_CreateNullMatrix(lua_State *L) {
    int nr = (int)luaL_checkinteger(L, 1);
    int nc = (int)luaL_checkinteger(L, 2);
    mat_new(L, nr, nc);   /* already zero-initialised */
    return 1;
}

static int mat_IsMatrix(lua_State *L) {
    if (mat_test(L, 1)) {
        lua_pushboolean(L, 1);
        lua_pushliteral(L, "matrix");
    } else {
        lua_pushboolean(L, 0);
        lua_pushstring(L, luaL_typename(L, 1));
    }
    return 2;
}

/* ── methods ─────────────────────────────────────────────────────── */

static int mat_map(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    luaL_checktype(L, 2, LUA_TFUNCTION);

    int total = m->nrows * m->ncols;
    Matrix *r = mat_new(L, m->nrows, m->ncols);

    for (int idx = 0; idx < total; idx++) {
        int row = idx / m->ncols + 1;
        int col = idx % m->ncols + 1;

        lua_pushvalue(L, 2);              /* function            */

        /* pos table {i = row, j = col}  */
        lua_createtable(L, 0, 2);
        lua_pushinteger(L, row);
        lua_setfield(L, -2, "i");
        lua_pushinteger(L, col);
        lua_setfield(L, -2, "j");

        lua_pushnumber(L, m->data[idx]);  /* current value       */
        lua_call(L, 2, 1);

        if (lua_isnumber(L, -1))
            r->data[idx] = lua_tonumber(L, -1);
        else
            r->data[idx] = m->data[idx];
        lua_pop(L, 1);
    }

    return 1;
}

static int mat_isCompatibleForSum(lua_State *L) {
    Matrix *m1 = mat_check(L, 1);
    Matrix *m2 = mat_check(L, 2);
    lua_pushboolean(L, m1->nrows == m2->nrows && m1->ncols == m2->ncols);
    return 1;
}

static int mat_isCompatibleForMult(lua_State *L) {
    Matrix *m1 = mat_check(L, 1);
    Matrix *m2 = mat_check(L, 2);
    lua_pushboolean(L, m1->ncols == m2->nrows);
    return 1;
}

static int mat_isSquare(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    lua_pushboolean(L, m->nrows == m->ncols);
    return 1;
}

static int mat_submatrix(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    int skip_row = (int)luaL_checkinteger(L, 2);
    int skip_col = (int)luaL_checkinteger(L, 3);

    int nr = m->nrows - 1;
    int nc = m->ncols - 1;
    if (nr < 1 || nc < 1)
        return luaL_error(L, "cannot extract submatrix from 1-dimensional matrix");

    Matrix *r = mat_new(L, nr, nc);
    int di = 0;
    for (int i = 1; i <= m->nrows; i++) {
        if (i == skip_row) continue;
        for (int j = 1; j <= m->ncols; j++) {
            if (j == skip_col) continue;
            r->data[di++] = m->data[(i - 1) * m->ncols + (j - 1)];
        }
    }
    return 1;
}

static int mat_determinant(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    if (m->nrows != m->ncols)
        return luaL_error(L, "determinant requires a square matrix");

    lua_pushnumber(L, det_flat(m->data, m->nrows));
    return 1;
}

static int mat_T(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    Matrix *r = mat_new(L, m->ncols, m->nrows);

    for (int i = 0; i < m->nrows; i++)
        for (int j = 0; j < m->ncols; j++)
            r->data[j * m->nrows + i] = m->data[i * m->ncols + j];
    return 1;
}

/* ── metamethods ─────────────────────────────────────────────────── */

static int mat_add(lua_State *L) {
    Matrix *m1 = mat_check(L, 1);
    Matrix *m2 = mat_check(L, 2);
    if (m1->nrows != m2->nrows || m1->ncols != m2->ncols)
        return luaL_error(L, "Matrices must have the same dimensions for addition.");

    int n = m1->nrows * m1->ncols;
    Matrix *r = mat_new(L, m1->nrows, m1->ncols);
    for (int i = 0; i < n; i++) r->data[i] = m1->data[i] + m2->data[i];
    return 1;
}

static int mat_sub(lua_State *L) {
    Matrix *m1 = mat_check(L, 1);
    Matrix *m2 = mat_check(L, 2);
    if (m1->nrows != m2->nrows || m1->ncols != m2->ncols)
        return luaL_error(L, "Matrices must have the same dimensions for subtraction.");

    int n = m1->nrows * m1->ncols;
    Matrix *r = mat_new(L, m1->nrows, m1->ncols);
    for (int i = 0; i < n; i++) r->data[i] = m1->data[i] - m2->data[i];
    return 1;
}

static int mat_mul(lua_State *L) {
    Matrix *ma = mat_test(L, 1);
    Matrix *mb = mat_test(L, 2);

    if (ma && mb) {
        /* Matrix × Matrix */
        if (ma->ncols != mb->nrows)
            return luaL_error(L,
                "incompatible dimensions for multiplication: A has %d cols, B has %d rows",
                ma->ncols, mb->nrows);

        Matrix *r = mat_new(L, ma->nrows, mb->ncols);
        for (int i = 0; i < ma->nrows; i++) {
            for (int j = 0; j < mb->ncols; j++) {
                double sum = 0;
                for (int k = 0; k < ma->ncols; k++)
                    sum += ma->data[i * ma->ncols + k] * mb->data[k * mb->ncols + j];
                r->data[i * mb->ncols + j] = sum;
            }
        }
        return 1;
    }

    if (ma && lua_isnumber(L, 2)) {
        double s = lua_tonumber(L, 2);
        int n = ma->nrows * ma->ncols;
        Matrix *r = mat_new(L, ma->nrows, ma->ncols);
        for (int i = 0; i < n; i++) r->data[i] = ma->data[i] * s;
        return 1;
    }

    if (mb && lua_isnumber(L, 1)) {
        double s = lua_tonumber(L, 1);
        int n = mb->nrows * mb->ncols;
        Matrix *r = mat_new(L, mb->nrows, mb->ncols);
        for (int i = 0; i < n; i++) r->data[i] = mb->data[i] * s;
        return 1;
    }

    return luaL_error(L, "unsupported operand types for multiplication");
}

static int mat_tostring(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    luaL_Buffer b;
    luaL_buffinit(L, &b);

    char buf[64];
    for (int i = 0; i < m->nrows; i++) {
        luaL_addstring(&b, "| ");
        for (int j = 0; j < m->ncols; j++) {
            snprintf(buf, sizeof(buf), "%.14g\t", m->data[i * m->ncols + j]);
            luaL_addstring(&b, buf);
        }
        luaL_addstring(&b, "|\n");
    }

    luaL_pushresult(&b);
    return 1;
}

static int mat_concat(lua_State *L) {
    luaL_tolstring(L, 1, NULL);
    luaL_tolstring(L, 2, NULL);
    lua_concat(L, 2);
    return 1;
}

static int mat_index(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    int t = lua_type(L, 2);

    /* m[{i, j}]  or  m[{i=1, j=2}] */
    if (t == LUA_TTABLE) {
        int i = mat_get_ij(L, 2, 1, "i");
        int j = mat_get_ij(L, 2, 2, "j");
        int r = mod_pos(i - 1, m->nrows);
        int c = mod_pos(j - 1, m->ncols);
        lua_pushnumber(L, m->data[r * m->ncols + c]);
        return 1;
    }

    /* m[k] — linear access */
    if (t == LUA_TNUMBER) {
        int k = (int)lua_tointeger(L, 2);
        if (k >= 1 && k <= m->nrows * m->ncols) {
            lua_pushnumber(L, m->data[k - 1]);
            return 1;
        }
        lua_pushnil(L);
        return 1;
    }

    /* string key — properties and method lookup */
    if (t == LUA_TSTRING) {
        const char *key = lua_tostring(L, 2);

        if (strcmp(key, "nrows") == 0) { lua_pushinteger(L, m->nrows); return 1; }
        if (strcmp(key, "ncols") == 0) { lua_pushinteger(L, m->ncols); return 1; }
        if (strcmp(key, "type")  == 0) { lua_pushliteral(L, "matrix"); return 1; }

        /* .data → builder closure bound to this matrix */
        if (strcmp(key, "data") == 0) {
            lua_pushvalue(L, 1);                         /* upvalue: matrix ud */
            lua_pushcclosure(L, mat_data_fill, 1);
            return 1;
        }

        /* look up in metatable (methods) */
        luaL_getmetatable(L, MATRIX_MT);
        lua_pushvalue(L, 2);
        lua_rawget(L, -2);
        return 1;
    }

    lua_pushnil(L);
    return 1;
}

static int mat_newindex(lua_State *L) {
    Matrix *m = mat_check(L, 1);
    int t = lua_type(L, 2);

    if (t == LUA_TTABLE) {
        int i = mat_get_ij(L, 2, 1, "i");
        int j = mat_get_ij(L, 2, 2, "j");
        m->data[(i - 1) * m->ncols + (j - 1)] = luaL_checknumber(L, 3);
        return 0;
    }

    if (t == LUA_TNUMBER) {
        int k = (int)lua_tointeger(L, 2);
        if (k >= 1 && k <= m->nrows * m->ncols)
            m->data[k - 1] = luaL_checknumber(L, 3);
        return 0;
    }

    return 0;
}

/* ── registration tables ─────────────────────────────────────────── */

static const luaL_Reg mat_methods[] = {
    {"map",                 mat_map},
    {"isCompatibleForSum",  mat_isCompatibleForSum},
    {"isCompatibleForMult", mat_isCompatibleForMult},
    {"isSquare",            mat_isSquare},
    {"submatrix",           mat_submatrix},
    {"determinant",         mat_determinant},
    {"T",                   mat_T},
    {NULL, NULL}
};

static const luaL_Reg mat_meta[] = {
    {"__add",      mat_add},
    {"__sub",      mat_sub},
    {"__mul",      mat_mul},
    {"__tostring", mat_tostring},
    {"__concat",   mat_concat},
    {"__index",    mat_index},
    {"__newindex",  mat_newindex},
    {NULL, NULL}
};

static const luaL_Reg mat_module[] = {
    {"CreateMatrix",       mat_CreateMatrix},
    {"CreateColumnMatrix", mat_CreateColumnMatrix},
    {"CreateRowMatrix",    mat_CreateRowMatrix},
    {"CreateNullMatrix",   mat_CreateNullMatrix},
    {"IsMatrix",           mat_IsMatrix},
    {NULL, NULL}
};

/* ── module entry point ──────────────────────────────────────────── */

int luaopen_matrix(lua_State *L) {
    /* metatable */
    luaL_newmetatable(L, MATRIX_MT);
    luaL_setfuncs(L, mat_meta, 0);
    luaL_setfuncs(L, mat_methods, 0);
    lua_pop(L, 1);

    /* module table */
    luaL_newlib(L, mat_module);
    return 1;
}
