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

Requirements: Lua >= 5.2

### Using LuaRocks (local install from this repo)

```bash
luarocks make rockspecs/vmsl-1.0-1.rockspec
```

Then, in your code:

```lua
local V = require("vectors")
local M = require("matrix")
-- ou
local VMSL = require("VMSL")
local V = VMSL.vectors
local M = VMSL.matrix
```

### Without LuaRocks (adjusting package.path)

Point your `package.path` to this repo and require the modules:

```lua
-- Adapt the path below to where you cloned this repository
package.path = package.path .. ";/path/to/VectorAndMatrixSystemLua/?/init.lua"

local V = require("vectors")
local M = require("matrix")
```

Note: there is a root `init.lua` that exposes both modules through a single table:

```lua
local VMSL = require("VMSL")
local V = VMSL.vectors
local M = VMSL.matrix
```

Requiring `vectors` and `matrix` directly is often the clearest approach at this stage.

## Quick start

```lua
-- Vectors
local V = require("vectors")
local v1 = V.CreateVector(1, 2, 3)
local v2 = V.CreateVector(4, 5, 6)

print(v1)                 -- Vector3:{ 1, 2, 3 }
print(#v1)                -- 3 (dimension)
print("dot:", v1:dot(v2)) -- 32

local v3 = v1 + v2        -- component-wise sum
print(v3)                 -- Vector3:{ 5, 7, 9 }

-- Matrices
local M = require("matrix")
local A = M.transformInMatrix({
  {1, 2},
  {3, 4}
})

print(A)
-- | 1    2    |
-- | 3    4    |

print("det(A):", A:determinant()) -- -2
```

> API stability: experimental. Names, signatures and behavior may change as the project evolves.

## API style

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
- Automated tests for base and edge cases.
- Additional operations for matrices and vectors (matrix multiplication, transpose, norms, etc.).

## Contributing

Suggestions, issues and PRs are welcome. This is a hobby project, so responses might be slow — thanks for understanding.

## Credits and license

Personal project by @pessoa736. If you use it, please keep attribution.

License: MIT.
