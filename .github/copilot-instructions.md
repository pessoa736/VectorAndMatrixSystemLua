# Copilot Instructions — VMSL (Vector and Matrix System Lua)

## Visão geral do projeto

Biblioteca Lua leve para criação e manipulação de vetores N-dimensionais e matrizes M×N, voltada para jogos e simulações. O pacote é distribuído via LuaRocks como `vmsl`.

- **Linguagem:** Lua >= 5.4 (usa operador `//`, `table.unpack`)
- **Licença:** MIT
- **Status:** API experimental — nomes, assinaturas e comportamento podem mudar

## Estrutura do projeto

```
vectors/
  core.lua              # Ponto de entrada: require("vectors")
  vectorAssembler.lua   # Fábricas: CreateVector, IsVector, CreateConstVector, etc.
  ops/                  # Operações (cada arquivo = uma responsabilidade)
    common.lua          # Metamétodos: __add, __sub, __mul, __unm, __len, __tostring
    dot.lua             # Produto escalar (Dot)
    cross.lua           # Produto vetorial generalizado (Cross)
    projection.lua      # Projeção vetorial
    map.lua             # Iteração/mapeamento sobre componentes
    checks.lua          # Verificações de equipolência e tipo
    circumference.lua   # Operações de circunferência
  utils/
    parseCoefficients.lua
  tests/                # Testes de benchmark (sem framework de asserção)

matrix/
  core.lua              # Ponto de entrada: require("matrix")
  MatrixAssembler.lua   # Fábricas: CreateMatrix, CreateRowMatrix, CreateColumnMatrix, etc.
  definitions.lua       # (reservado para definições futuras)
  mathUtils.lua         # Utilitários matemáticos auxiliares
  ops/                  # Operações de matriz
    common.lua          # Metamétodos: __add, __sub, __mul, __tostring
    check.lua           # Verificações de compatibilidade dimensional
    map.lua             # Map sobre elementos da matriz
    submatrix.lua       # Extração de submatrizes
    determinat.lua      # Cálculo de determinante (nota: nome do arquivo tem typo)
    translation.lua     # Transposição/translação
  tests/                # Testes de benchmark

rockspecs/              # Especificações LuaRocks
```

## Padrões de arquitetura

### Padrão de módulo — Factory Function

Cada arquivo em `ops/` exporta uma **função fábrica** que recebe o sistema pai (`MatrixSystem` ou `VectorSystem`) como closure e retorna uma tabela de operações:

```lua
-- Padrão obrigatório para novos módulos de operação
return function(MatrixSystem)   -- ou VectorSystem
    local ops = {}

    function ops.minhaOperacao(self, ...)
        -- implementação
    end

    return ops
end
```

As operações são registradas na metatabela compartilhada via `addProperties` nos arquivos `core.lua`.

### Padrão Assembler

Construtores de objetos ficam nos módulos Assembler (`MatrixAssembler.lua`, `vectorAssembler.lua`). O Assembler recebe a metatabela e retorna a tabela do sistema com as funções de criação.

### Metatabelas

- **Uma metatabela compartilhada** por tipo (`Properties` para matrizes, `properties` para vetores).
- Vetores armazenam dados em `self.points[]`, dimensão em `self.Dimensions`.
- Matrizes armazenam dados em `self.data[]` (linear, row-major), dimensões em `self.nrows` / `self.ncols`.
- Acesso por índice composto: `m[{i, j}]` ou `m[{i=1, j=2}]` para matrizes.
- Discriminação de tipo via campo `.type` (`"matrix"` ou `"vector"`).

## Convenções de código

### Nomenclatura

| Elemento | Convenção | Exemplos |
|---|---|---|
| Funções construtoras | PascalCase | `CreateVector`, `CreateMatrix`, `CreateNullMatrix` |
| Operações matemáticas (vetores) | PascalCase | `Dot`, `Cross`, `Circumference` |
| Operações matemáticas (matrizes) | camelCase | `map`, `determinant`, `submatrix` |
| Metamétodos | prefixo `__` (padrão Lua) | `__add`, `__mul`, `__tostring` |
| Variáveis locais | curtas/abreviadas | `m`, `v1`, `nr`, `nc`, `s` |
| Nomes de arquivo | camelCase ou lowercase | `vectorAssembler.lua`, `common.lua` |
| Verificadores de tipo | PascalCase com prefixo `Is` | `IsVector`, `IsMatrix` |

### Idioma

- **Comentários:** mistura de português e inglês (preferir inglês para novo código).
- **Mensagens de erro:** preferencialmente em inglês para interoperabilidade.
- **Documentação (README):** versões em inglês e português.

### Tratamento de erros

- Usar `error("mensagem descritiva")` com mensagens em inglês.
- Validar dimensões e tipos antes de operar (sem `pcall`/`xpcall`).
- Verificar compatibilidade com funções como `checkEquipollence`, `isCompatibleForSum`, `isCompatibleForMult`.

### Estilo de código

- Sem ponto-e-vírgula no final das linhas (exceto casos raros já existentes).
- Indentação com **4 espaços**.
- `local` para todas as variáveis e funções (evitar globais).
- Usar `table.unpack` em vez de `unpack` global.
- Strings com aspas duplas (`"`) como padrão.

## Criação de novos módulos de operação

1. Criar o arquivo em `vectors/ops/` ou `matrix/ops/`.
2. Seguir o padrão factory function que retorna tabela de operações.
3. Registrar o módulo no respectivo `core.lua` via `addProperties(require("caminho.do.modulo"))`.
4. Cada operação recebe `self` como primeiro parâmetro (chamada com `:`).

## Testes

- Testes ficam em `vectors/tests/` e `matrix/tests/`.
- Usar `TestFunctions.lua` local para utilitários de benchmark (`setStart`, `setFinal`, `showtime`, `reapeatTest`).
- Testes atuais são benchmarks de performance, não asserções de corretude.
- Executar testes diretamente: `lua matrix/tests/create.lua` ou `lua vectors/tests/cross/3D.lua`.

## Dependências

- **Lua** >= 5.4
- **loglua** (listada no rockspec)
- Não usar `table.create` (extensão Luau — incompatível com Lua padrão)

## Notas importantes

- A API é **experimental** — priorizar simplicidade e legibilidade.
- Manter compatibilidade com o padrão factory function ao adicionar operações.
- Operador `#` em vetores retorna dimensão (via `__len`), não o tamanho da tabela.
- Multiplicação vetor × vetor (`__mul`) delega para `Dot` (produto escalar).
- Multiplicação escalar × matriz e matriz × matriz são tratadas no mesmo `__mul`.
