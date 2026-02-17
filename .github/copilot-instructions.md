# Copilot Instructions — VMSL (Vector and Matrix System Lua)

## Visão geral do projeto

Biblioteca Lua para criação e manipulação de vetores N-dimensionais e matrizes M×N, voltada para jogos e simulações. O core é implementado em **C** (Lua C API) para máximo desempenho. O pacote é distribuído via LuaRocks como `vmsl`.

- **Linguagem:** C (Lua C API) + Lua >= 5.4
- **Licença:** MIT
- **Status:** API experimental — nomes, assinaturas e comportamento podem mudar

## Estrutura do projeto

```
src/
  vector.c              # Módulo C: luaopen_vectors (require("vectors"))
  matrix.c              # Módulo C: luaopen_matrix  (require("matrix"))

vectors/                # Implementação Lua legada (referência)
  core.lua
  vectorAssembler.lua
  ops/
  utils/
  tests/

matrix/                 # Implementação Lua legada (referência)
  core.lua
  MatrixAssembler.lua
  ops/
  tests/

types/
  vmsl.lua              # Definições de tipo LuaLS (@meta)

rockspecs/              # Especificações LuaRocks
Makefile                # Build dos módulos C (.so/.dll)
```

## Arquitetura C

### Estruturas de dados

Vetores e matrizes são **userdata** com flexible array members:

```c
typedef struct {
    int dim;
    double pts[];       /* componentes do vetor */
} Vector;               /* metatable: "VMSL.Vector" */

typedef struct {
    int nrows;
    int ncols;
    double data[];      /* row-major */
} Matrix;               /* metatable: "VMSL.Matrix" */
```

### Padrões C obrigatórios

- Cada módulo exporta `luaopen_<nome>` como ponto de entrada
- Helpers `*_new`, `*_check`, `*_test` para criar/validar userdata
- Métodos registrados na metatable com `luaL_setfuncs`
- `__index` customizado: numérico → dados, string → propriedade/método, table → acesso `{i,j}` (matrizes)
- Alocação via `lua_newuserdata` (GC gerenciado pelo Lua)
- `malloc`/`free` apenas para buffers temporários (determinante, cross product)

### Builder pattern (matrizes)

`CreateMatrix(nr, nc).data(...)` funciona via:
1. `__index` intercepta key `"data"` → retorna C closure
2. A closure tem o userdata como upvalue
3. Quando chamada, preenche `m->data[]` e retorna o userdata

## API pública

### Vector (`require("vectors")`)

| Função/Método | Descrição |
|---|---|
| `CreateVector(...)` | Cria vetor N-dimensional |
| `CreateConstVector(n, val)` | Vetor de dimensão `n`, todos = `val` |
| `CreateVectorZero(n)` | Vetor nulo |
| `CreateVectorOne(n)` | Vetor unitário |
| `IsVector(t)` → `bool, string` | Verifica tipo |
| `v:Dot(v2)` | Produto escalar ou multiplicação escalar |
| `v:Cross(...)` | Produto vetorial (2D, 3D, nD) |
| `v:projection(v2)` | Projeção de v2 sobre v |
| `v:map(fn)` | Aplica `fn(dim, val)` a cada componente |
| `v:checkEquipollence(v2)` | Verifica mesma dimensão |
| `Circumference.getRadius(v1, v2)` | Distância ao quadrado |
| `Circumference.getPerimeter(v1, v2)` | Perímetro |
| `v[k]` | Acesso ao componente k |
| `v.Dimensions`, `v.type`, `v.points` | Propriedades |
| `+`, `-`, `*`, `#`, `-v`, `..` | Operadores |

### Matrix (`require("matrix")`)

| Função/Método | Descrição |
|---|---|
| `CreateMatrix(nr, nc)` | Cria matriz (preencher com `.data(...)`) |
| `CreateRowMatrix(...)` | Matriz-linha (n×1) |
| `CreateColumnMatrix(...)` | Matriz-coluna (1×n) |
| `CreateNullMatrix(nr, nc)` | Matriz zero |
| `IsMatrix(t)` → `bool, string` | Verifica tipo |
| `m:map(fn)` | Aplica `fn({i,j}, val)` a cada elemento |
| `m:determinant()` | Determinante (matriz quadrada) |
| `m:submatrix(row, col)` | Remove linha e coluna |
| `m:T()` | Transposta |
| `m:isCompatibleForSum(m2)` | Verifica dimensões para soma |
| `m:isCompatibleForMult(m2)` | Verifica dimensões para multiplicação |
| `m:isSquare()` | Verifica se é quadrada |
| `m[{i,j}]`, `m[{i=1,j=2}]` | Acesso por posição |
| `m[k]` | Acesso linear |
| `m.nrows`, `m.ncols`, `m.type` | Propriedades |
| `+`, `-`, `*`, `..` | Operadores |

## Convenções de código

### C

- Indentação com **4 espaços**
- Prefixo `vec_` para funções de vetor, `mat_` para matriz
- `static` para todas as funções internas (apenas `luaopen_*` é exportada)
- Mensagens de erro em inglês via `luaL_error`
- Usar `luaL_Buffer` para construção de strings
- Flexible array members (C99) para dados contíguos
- Liberar buffers temporários com `free()` antes de qualquer `return`

### Lua (testes / código legado)

- Indentação com **4 espaços**
- `local` para todas as variáveis
- Strings com aspas duplas (`"`)
- Comentários preferencialmente em português

### Nomenclatura

| Elemento | Convenção | Exemplos |
|---|---|---|
| Funções construtoras | PascalCase | `CreateVector`, `CreateMatrix` |
| Operações (vetores) | PascalCase | `Dot`, `Cross` |
| Operações (matrizes) | camelCase | `map`, `determinant`, `submatrix` |
| Verificadores de tipo | PascalCase com `Is` | `IsVector`, `IsMatrix` |
| Funções C internas | snake_case com prefixo | `vec_add`, `mat_mul` |
| Macros | UPPER_CASE | `VECTOR_MT`, `MATRIX_MT` |

## Build

```bash
make                    # compila vectors.so e matrix.so
make install            # instala em LUA_CMOD
make clean              # limpa artefatos

# Variáveis configuráveis:
# LUA_VERSION=5.4  LUA_INC=...  LUA_CMOD=...

# Via LuaRocks:
luarocks make rockspecs/vmsl-1.1-1.rockspec
```

## Testes

- Testes ficam em `vectors/tests/` e `matrix/tests/`
- Executar com `lua5.4 -e 'package.cpath=...;./?.so"' <test_file>`
- `TestFunctions.lua` fornece utilitários de benchmark

## Dependências

- **Lua** >= 5.4 (headers: `lua.h`, `lauxlib.h`)
- **Compilador C** com suporte a C99 (flexible array members)
- Sem dependências externas de runtime

## Notas importantes

- A API é **experimental** — priorizar simplicidade e legibilidade
- Operador `#` em vetores retorna dimensão (via `__len`)
- `v * v` → dot product (`__mul` delega para `Dot`)
- Acesso `m.data(...)` é um builder pattern via closure C
- Determinante usa expansão de cofatores (O(n!)) — adequado para matrizes pequenas
- Os arquivos Lua em `vectors/` e `matrix/` são a implementação legada mantida como referência
