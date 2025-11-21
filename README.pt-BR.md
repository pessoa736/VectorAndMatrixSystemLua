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

Requisitos: Lua >= 5.4

### Usando LuaRocks (instalação local a partir deste repositório)

```bash
luarocks make rockspecs/vmsl-1.0-4.rockspec
```

Depois, no seu código:

```lua
local V = require("vectors")    -- exportado de vectors/core.lua
local M = require("matrix")     -- exportado de matrix/core.lua
```

Mudança quebrando (desde 1.0-3): módulo agregador raiz `init.lua` foi removido; faça require direto.

### Sem LuaRocks (ajustando package.path)

Aponte o `package.path` para este repositório e faça o require dos módulos:

```lua
-- Ajuste o caminho; incluímos padrões para encontrar core.lua
package.path = package.path .. ";/caminho/para/VectorAndMatrixSystemLua/?.lua;/caminho/para/VectorAndMatrixSystemLua/?/core.lua"

local V = require("vectors")
local M = require("matrix")
```

O agregador raiz foi removido; use require direto.

## Uso rápido

```lua
-- Vetores básicos
local V = require("vectors")
local v1 = V.CreateVector(1, 2, 3)
local v2 = V.CreateVector(4, 5, 6)

print(v1)                 -- Vector3:{ 1,  2,  3 }
print(#v1)                -- 3 (dimensão)
print("dot:", v1:Dot(v2)) -- 32 (nome interno capitalizado)

local v3 = v1 + v2            -- soma componente a componente (__add)
print(v3)                 -- Vector3:{ 5,  7,  9 }

-- Criação de matrizes
local M = require("matrix")
local A = M.CreateMatrix(2,2).data(1,2,3,4)
local B = M.CreateRowMatrix(1,2,3)      -- 1x3
local C = M.CreateColumnMatrix(4,5,6)   -- 3x1
local Z = M.CreateNullMatrix(2,3)       -- 2x3 zeros

print(A)
-- | 1    2    |
-- | 3    4    |

print("det(A):", A:determinant()) -- -2
print("A transposta:\n", A:T())

-- Produto vetorial (2D -> vetor perpendicular)
local v2d = V.CreateVector(3, 4)
print("cross 2D:", v2d:Cross())          -- Vector2:{ -4, 3 }

-- Produto vetorial (3D)
local v3a = V.CreateVector(1, 2, 3)
local v3b = V.CreateVector(2, 3, 1)
print("cross 3D:", v3a:Cross(v3b))       -- Vector3:{ -7, 5, -1 }

-- Produto vetorial generalizado (n>3): requer n-1 vetores equipolentes
local v5a = V.CreateVector(1,2,0,1,3)
local v5b = V.CreateVector(0,1,1,2,1)
local v5c = V.CreateVector(3,1,0,0,2)
local v5d = V.CreateVector(1,0,2,1,1)
local ort5 = v5a:Cross(v5b, v5c, v5d)
print("cross 5D:", ort5)
```

> Estabilidade da API: experimental. Nomes, assinaturas e comportamentos podem mudar conforme o projeto evolui.

## Estilo e superfície da API

Criação de vetores (seleção):
| Função | Descrição |
|--------|-----------|
| `CreateVector(...)` | Cria vetor a partir de coordenadas numéricas. Erra se vazio ou não-numérico. |
| `CreateConstVector(dim, valor)` | Preenche todas as posições. Defaults: dim=1, valor=0. |
| `CreateVectorZero(n)` | Vetor de zeros. |
| `CreateVectorOne(n)` | Vetor de uns. |

Operações em vetores:
| Operação | Forma | Notas |
|----------|------|-------|
| Soma | `v1 + v2` | Mesma dimensão. |
| Subtração | `v1 - v2` | Mesma dimensão. |
| Menos unário | `-v` | Negação componente. |
| Produto escalar | `v1:Dot(v2)` ou `v1 * v2` | Escalar se ambos vetores. |
| Escalar à direita | `v * k` | Multiplica cada componente. |
| Map | `v:map(function(i,val) ... end)` | Retorna novo vetor. |
| Projeção | `v1:projection(v2)` | Projeção de v2 sobre v1. |
| Cross 2D | `v:Cross()` | Perpendicular `(-y,x)`. |
| Cross 3D | `v1:Cross(v2)` | Fórmula clássica. |
| Cross n>3 | `v1:Cross(v2,...,v_{n-1})` | Vetor ortogonal via cofatores. |
| Dimensão | `#v` | Número de componentes. |
| Equipolência | `v1:checkEquipollence(v2)` | Bool + dimensão. |

Criação de matrizes:
| Função | Descrição |
|--------|-----------|
| `CreateMatrix(linhas,colunas)` | Cria matriz vazia; preencher com `.data(...)`. |
| `CreateRowMatrix(...)` | 1×N. |
| `CreateColumnMatrix(...)` | N×1. |
| `CreateNullMatrix(r,c)` | Zeros. |

Operações em matrizes:
| Operação | Forma | Notas |
|----------|------|-------|
| Soma | `A + B` | Mesma forma. |
| Subtração | `A - B` | Mesma forma. |
| Escalar | `k * A` ou `A * k` | Escala todos os elementos. |
| Multiplicação | `A * B` | `A.ncols == B.nrows`. |
| Map | `A:map(function(pos,val) ... end)` | `pos.i`, `pos.j`. |
| Transposta | `A:T()` | Retorna `A^T`. |
| Determinante | `A:determinant()` | Recursivo (lento para n grande). |
| Submatriz | `A:submatrix(i,j)` | Menor (remove linha i e coluna j). |

Versão / dependências:
- Lua mínima agora 5.4 (rockspec 1.0-3).
- Removido módulo agregador raiz.
- Exporta módulos diretamente `vectors`, `matrix`.

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
- Testes automatizados abrangendo criação, aritmética e erros.
- Normas, distâncias, ângulos para vetores.
- Determinante LU / Gauss + inversão de matrizes.
- Produto vetorial generalizado via espaço nulo (mais rápido).
- Suporte a `numero * vetor` (lado esquerdo).
- Benchmarks + camada opcional de otimizações.

## Comportamento do produto vetorial

| Dimensão | Padrão de chamada                      | Resultado |
|----------|----------------------------------------|-----------|
| 2D       | `v:Cross()`                            | Vetor perpendicular `(-y, x)` |
| 3D       | `v1:Cross(v2)`                         | Produto vetorial clássico |
| n>3      | `v1:Cross(v2, ..., v_{n-1})`           | Produto vetorial generalizado (cofatores), ortogonal a todos |

Regras:
- Todos os vetores devem ser equipolentes (mesma dimensão) ou ocorre erro.
- Para n>3 deve haver exatamente n-1 vetores no total (o receptor + n-2 extras).
- Implementação para n>3 usa cofatores (expansão de Laplace) e é MUITO cara para n grande (crescimento fatorial) e pode gerar números enormes.

Notas de desempenho:
- 2D/3D: O(1), rápido.
- n>3: exponencial; evite para n>7 salvo necessidade real. Futuro: usar eliminação Gaussiana / espaço nulo.

## Mudanças recentes (desde <=1.0-1)

- Rockspec agora referencia diretamente `matrix/core.lua` e `vectors/core.lua`.
- Incluído `checkEquipollence`; corrigidos erros de método nil em dot/cross.
- Helpers de criação de vetor documentados (`CreateConstVector`, `Zero`, `One`).
- Produto vetorial refeito (2D, 3D, n>3 cofatores).
- Corrigido bug do cross 2D com vetor sem dimensão.
- Adicionado multiplicação escalar-matriz bilateral.
- Adicionada transposta `T`.
- Multiplicação de matrizes com verificação de forma.

## Limitações / observações

- Multiplicação escalar à esquerda (`numero * vetor`) ainda indisponível.
- Produto vetorial n>3: custo fatorial / magnitudes grandes; normalize se preciso.
- Determinante lento para matrizes grandes (expansão de Laplace).
- Sem inversão / normas / distância ainda.
- Caminho simbólico legado pode ser removido futuramente.

## Normalizando resultado de produto vetorial grande

Exemplo:
```lua
local grande = v5a:Cross(v5b, v5c, v5d)
local len2 = 0
grande:map(function(_, v) len2 = len2 + v*v end)
local len = math.sqrt(len2)
local unitario = grande:map(function(_, v) return v / len end)
print("ortogonal unitário:", unitario)
```

## Contribuindo

Sugestões, issues e PRs são bem-vindos. É um projeto de hobby, então respostas podem demorar um pouco — obrigado pela compreensão.

## Créditos e licença

Projeto pessoal de @pessoa736. Se usar, por favor mantenha os créditos.

Licença: MIT.
