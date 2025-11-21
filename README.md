# Vector and Matrix System (Lua)

Read this in Portuguese (Brasil): [README.pt-BR.md](./README.pt-BR.md)

A tiny Lua library to create and manipulate mathematical vectors and matrices in N dimensions, with a focus on simplicity and quick start. Initially built for personal use in games/simulations, but anyone can use it (please keep attribution).

> Status: work in progress. The API is experimental and may change without notice.

## What it is

- N-dimensional vectors with basic operations (addition, subtraction, dot product, etc.).
- M×N matrices with essential operations (element mapping, determinant for square matrices, etc.).
- Pragmatic and lightweight: easy to read and easy to start using.

## Why

This is a hobby project for my own needs (games/simulations). If it helps you, feel free to use it — attribution is appreciated.

## Installation

Requirements: Lua >= 5.4

### Using LuaRocks (local install from this repo)

```bash
luarocks make rockspecs/vmsl-1.0-4.rockspec
```

Then, in your code:

```lua
local V = require("vectors")    -- exports from vectors/core.lua
local M = require("matrix")     -- exports from matrix/core.lua
```

Breaking change (since 1.0-3): the root `init.lua` aggregator module was removed; require modules directly.

### Without LuaRocks (adjusting package.path)

Point your `package.path` to this repo and require the modules:

```lua
-- Adapt the path; we append both module roots
package.path = package.path .. ";/path/to/VectorAndMatrixSystemLua/?.lua;/path/to/VectorAndMatrixSystemLua/?/core.lua"

local V = require("vectors")  -- vectors/core.lua via rockspec mapping or custom path
local M = require("matrix")   -- matrix/core.lua
```

Root aggregator no longer exists; prefer direct requires.

## Quick start

```lua
-- Vectors basics
local V = require("vectors")
local v1 = V.CreateVector(1, 2, 3)
local v2 = V.CreateVector(4, 5, 6)

print(v1)                 -- Vector3:{ 1, 2, 3 }
print(#v1)                -- 3 (dimension)
print("dot:", v1:Dot(v2)) -- 32 (capitalized internal name; colon allows method)

local v3 = v1 + v2            -- component-wise sum (uses __add)
print(v3)                 -- Vector3:{ 5, 7, 9 }

-- Matrix creation
local M = require("matrix")
local A = M.CreateMatrix(2,2).data(1,2,3,4)   -- row-major fill
local B = M.CreateRowMatrix(1,2,3)            -- 3x1
local C = M.CreateColumnMatrix(4,5,6)         -- 1x3
local Z = M.CreateNullMatrix(2,3)             -- 2x3 all zeros

print(A)
-- | 1    2    |
-- | 3    4    |

print("det(A):", A:determinant()) -- -2
print("A transpose:\n", A:T())    -- __tostring prints nicely

-- Cross product (2D -> perpendicular vector)
local v2d = V.CreateVector(3, 4)
print("cross 2D:", v2d:Cross())        -- Vector2:{ -4, 3 }

-- Cross product (3D)
local v3a = V.CreateVector(1, 2, 3)
local v3b = V.CreateVector(2, 3, 1)
print("cross 3D:", v3a:Cross(v3b))     -- Vector3:{ -7, 5, -1 }

-- Generalized cross product (n>3): need n-1 equipollent vectors
-- Example for 5D: result is a vector orthogonal to all given vectors
local v5a = V.CreateVector(1,2,0,1,3)
local v5b = V.CreateVector(0,1,1,2,1)
local v5c = V.CreateVector(3,1,0,0,2)
local v5d = V.CreateVector(1,0,2,1,1)
local orth5 = v5a:Cross(v5b, v5c, v5d)
print("cross 5D:", orth5)
```

> API stability: experimental. Names, signatures and behavior may change as the project evolves.

## API style & surface

Vector factory (selected):
| Function | Description |
|----------|-------------|
| `CreateVector(...)` | Build a vector from numeric coordinates. Errors if any argument is non-number or empty list. |
| `CreateConstVector(dim,value)` | Fill vector with `value` (defaults: dim=1,value=0). |
| `CreateVectorZero(n)` | Shorthand for all zeros. |
| `CreateVectorOne(n)` | Shorthand for all ones. |

Vector operations (methods via colon or metamethods):
| Operation | Form | Notes |
|-----------|------|-------|
| Addition | `v1 + v2` | Requires equipollence. |
| Subtraction | `v1 - v2` | Requires equipollence. |
| Unary minus | `-v` | Component negation. |
| Dot product | `v1:Dot(v2)` or `v1 * v2` | Scalar when both vectors; scalar-times-vector also supported (right side). |
| Map | `v:map(function(i,val) ... end)` | Returns new transformed vector. |
| Projection | `v1:projection(v2)` | Projection of v2 onto v1 (returns vector). |
| Cross (2D) | `v:Cross()` | Perpendicular `(-y,x)`. |
| Cross (3D) | `v1:Cross(v2)` | Standard cross product. |
| Cross (n>3) | `v1:Cross(v2, ..., v_{n-1})` | Generalized cofactor-based orthogonal vector. |
| Dimension | `#v` | Returns number of components. |
| Equipollence check | `v1:checkEquipollence(v2)` | Returns bool, dimension. |

Matrix factory:
| Function | Description |
|----------|-------------|
| `CreateMatrix(rows, cols)` | Creates empty then fill via `.data(...)`. |
| `CreateRowMatrix(...)` | 1×N row. |
| `CreateColumnMatrix(...)` | N×1 column. |
| `CreateNullMatrix(r,c)` | All zero entries. |

Matrix operations:
| Operation | Form | Notes |
|-----------|------|-------|
| Addition | `A + B` | Same shape required. |
| Subtraction | `A - B` | Same shape required. |
| Scalar mult | `k * A` or `A * k` | Returns scaled matrix. |
| Matrix mult | `A * B` | Requires `A.ncols == B.nrows`. Produces `(A.nrows x B.ncols)`. |
| Map | `A:map(function(pos,val) ... end)` | Returns new matrix. `pos.i`, `pos.j`. |
| Transpose | `A:T()` | Returns `A^T`. |
| Determinant | `A:determinant()` | Recursive (slow for large n). Square matrices only. |
| Extended determinant | `A:ExtendDeterminant()` | Internal symbolic/extended form (used previously). |
| Submatrix | `A:submatrix(i,j)` | Minor without row i, col j. |

Version / dependency changes:
- Lua minimum version raised from 5.2 to 5.4 in rockspec 1.0-3.
- Removed root aggregator module (`init.lua`).
- Modules exported directly as `vectors` and `matrix`.

- Style: Lua module API accessed via `require`.
- Surface: modules `vectors` and `matrix` are exposed directly, and also via root module `VMSL` (`VMSL.vectors`, `VMSL.matrix`).
- Stability: experimental/unstable for now. Functions, names and return values may change until things settle.

## Goals (high level)

- N-dimensional vectors with basic and utility operations.
- M×N matrices with core operations (addition, mapping, determinant, etc.).
- Make it easy to use in games/simulations through a simple, expressive interface.
- Keep the implementation straightforward and readable before micro-optimizations.

## Roadmap (short)

- Better docs (more examples and topic-based guides).
- LuaRocks packaging improvements.
- Automated tests (coverage: vector/matrix creation, arithmetic, error paths).
- Norms, distances, angle utilities for vectors.
- LU / Gaussian determinant + matrix inversion.
- Null-space based generalized cross product (faster for n>7).
- Left scalar multiplication support for vectors (`number * vector`).
- Performance benchmarks + optional optimization layer.

## Cross product behavior

| Dimension | Call pattern                          | Result |
|-----------|---------------------------------------|--------|
| 2D        | `v:Cross()`                           | Perpendicular vector `(-y, x)` |
| 3D        | `v1:Cross(v2)`                        | Classical cross product |
| n>3       | `v1:Cross(v2, ..., v_{n-1})`          | Generalized (cofactor-based) cross product, orthogonal to all input vectors |

Rules:
- All vectors must be equipollent (same dimensions) or an error is raised.
- For n>3 you must supply exactly n-1 vectors total (the receiver `v1` plus n-2 extra).
- Implementation for n>3 uses cofactors (Laplace expansion) and is VERY expensive for large n (factorial growth) and can overflow numeric ranges quickly.

Performance notes:
- 2D/3D versions are fast (O(1)).
- n>3 version is exponential; avoid for n>7 unless necessary. Future optimization will switch to a more efficient method (e.g. forming an (n-1)×n matrix and computing a null-space via Gaussian elimination).

## Recent changes (since <=1.0-1)

- Rockspec now maps directly to `matrix/core.lua` and `vectors/core.lua` (removed stale `init.lua`).
- Added `checkEquipollence` to vector ops; fixed nil method errors in dot/cross.
- Vector creation helpers: `CreateConstVector`, `CreateVectorZero`, `CreateVectorOne` documented.
- Cross product fully refactored (2D / 3D direct formulas; n>3 numeric cofactors).
- Fixed 2D cross "dimensionless vector" bug.
- Added scalar-matrix multiplication both sides.
- Added matrix transpose `T`.
- Matrix multiplication with shape checks.

## Known limitations / caveats

- Scalar multiplication left-associative (`number * vector`) still unsupported; use `vector * number`.
- Generalized cross product: factorial cost & large magnitudes; normalize if needed.
- Determinant: recursive Laplace expansion (slow, no numeric optimization yet).
- No matrix inversion / norms yet.
- Extended determinant symbolic path retained only for legacy; may be removed.

## Normalizing large cross product results

Example:
```lua
local big = v5a:Cross(v5b, v5c, v5d)
-- Normalize (L2)
local lenSq = 0
big:map(function(_, val) lenSq = lenSq + val*val end)
local len = math.sqrt(lenSq)
local unit = big:map(function(_, val) return val / len end)
print("unit orthogonal:", unit)
```

## Contributing

Suggestions, issues and PRs are welcome. This is a hobby project, so responses might be slow — thanks for understanding.

## Credits and license

Personal project by @pessoa736. If you use it, please keep attribution.

License: MIT.
