# Vector and Matrix System (Lua)

Leia em inglês: [README.md](./README.md)

Uma biblioteca em Lua para criar e manipular vetores e matrizes matemáticas em N dimensões, com foco em simplicidade e início rápido. Feita inicialmente para uso pessoal em jogos/simulações, mas qualquer pessoa pode usar (por favor mantenha os créditos).

> Status: em desenvolvimento. A API é experimental e pode mudar sem aviso.

## O que é

- Vetores em N dimensões com operações básicas (soma, subtração, produto escalar, etc.).
- Matrizes M×N com operações essenciais (mapeamento de elementos, determinante para quadradas, etc.).
- Pragmatismo e leveza: fácil de ler e começar a usar.

## Por quê

Projeto de hobby para minhas próprias necessidades (jogos/simulações). Se também te ajudar, sinta-se livre para usar — agradeço o crédito.

## Instalação

Requisitos: Lua >= 5.2

### Usando LuaRocks (instalação local a partir deste repositório)

```bash
luarocks make rockspecs/VectorAndMatrixSystem.rockspec
```

Depois, no seu código:

```lua
local V = require("vectors")
local M = require("matrix")
-- ou
local VMSL = require("VMSL")
local V = VMSL.vectors
local M = VMSL.matrix
```

### Sem LuaRocks (ajustando package.path)

Aponte o `package.path` para este repositório e faça o require dos módulos:

```lua
-- Adapte o caminho abaixo para onde você clonou este repositório
package.path = package.path .. ";/caminho/para/VectorAndMatrixSystemLua/?/init.lua"

local V = require("vectors")
local M = require("matrix")
```

Observação: existe um `init.lua` na raiz que expõe ambos os módulos através de uma única tabela:

```lua
local VMSL = require("VMSL")
local V = VMSL.vectors
local M = VMSL.matrix
```

Requerer `vectors` e `matrix` diretamente costuma ser o caminho mais claro neste estágio.

## Uso rápido

```lua
-- Vetores
local V = require("vectors")
local v1 = V.CreateVector(1, 2, 3)
local v2 = V.CreateVector(4, 5, 6)

print(v1)                 -- Vector3:{ 1,  2,  3 }
print(#v1)                -- 3 (dimensão)
print("dot:", v1:dot(v2)) -- 32

local v3 = v1 + v2        -- soma componente a componente
print(v3)                 -- Vector3:{ 5,  7,  9 }

-- Matrizes
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

> Estabilidade da API: experimental. Nomes, assinaturas e comportamentos podem mudar conforme o projeto evolui.

## Tipo de API

- Estilo: API de módulos Lua via `require`.
- Superfície: módulos `vectors` e `matrix` expostos diretamente, e também via módulo raiz `VMSL` (`VMSL.vectors`, `VMSL.matrix`).
- Estabilidade: experimental/instável por enquanto. Funções, nomes e retornos podem mudar até estabilizar.

## Objetivos (alto nível)

- Vetores em N dimensões com operações básicas e utilitárias.
- Matrizes M×N com operações principais (soma, mapeamento, determinante, etc.).
- Facilitar uso em jogos/simulações com interface simples e expressiva.
- Manter implementação direta e legível antes de micro‑otimizações.

## Roadmap (resumido)

- Melhorar documentação (mais exemplos e guias por tópico).
- Aprimorar empacotamento no LuaRocks.
- Testes automatizados para casos base e de borda.
- Operações adicionais para matrizes e vetores (multiplicação de matrizes, transposição, normas, etc.).

## Contribuindo

Sugestões, issues e PRs são bem-vindos. É um projeto de hobby, então respostas podem demorar um pouco — obrigado pela compreensão.

## Créditos e licença

Projeto pessoal de @pessoa736. Se usar, por favor mantenha os créditos.

Licença: MIT.
