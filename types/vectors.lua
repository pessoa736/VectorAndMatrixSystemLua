---@meta vectors
---@module "vectors"

-------------------------------------------------------------------------------
-- Vector
-------------------------------------------------------------------------------

---@class Vector
---@field Dimensions integer          Número de dimensões do vetor
---@field type "vector"               Discriminador de tipo
---@field points number[]             Componentes do vetor (indexadas a partir de 1)
---@operator add(Vector): Vector
---@operator sub(Vector): Vector
---@operator unm: Vector
---@operator mul(number): Vector
---@operator mul(Vector): number
---@operator len: integer
---@operator concat(any): string
local Vector = {}

--- Produto escalar entre dois vetores equipolentes, ou multiplicação escalar.
---@param v2 Vector|number
---@return number|Vector
function Vector:Dot(v2) end

--- Produto vetorial generalizado.
--- - 2D: sem argumentos extras, retorna o perpendicular.
--- - 3D: recebe 1 vetor extra.
--- - nD: recebe n-2 vetores extras.
---@param ... Vector
---@return Vector
function Vector:Cross(...) end

--- Produto vetorial otimizado para 2D e 3D.
---@param ... Vector
---@return Vector
function Vector:CrossProduct_2D_or_3D(...) end

--- Projeção de `self` sobre `v2`.
---@param v2 Vector
---@return Vector
function Vector:projection(v2) end

--- Aplica uma função a cada componente e retorna um novo vetor.
---@param fun fun(dim: integer, value: number): number?
---@return Vector
function Vector:map(fun) end

--- Verifica se dois vetores têm a mesma dimensão (equipolência).
---@param otherVector Vector
---@return boolean equipollent
---@return integer dimensions
function Vector:checkEquipollence(otherVector) end

-------------------------------------------------------------------------------
-- VectorCircumference — operações de circunferência
-------------------------------------------------------------------------------

---@class VectorCircumference
local VectorCircumference = {}

--- Calcula o raio (distância ao quadrado) entre dois vetores.
---@param v1 Vector
---@param v2 Vector
---@return number
function VectorCircumference.getRadius(v1, v2) end

--- Calcula o perímetro da circunferência definida por dois vetores.
---@param v1 Vector
---@param v2 Vector
---@return number
function VectorCircumference.getPerimeter(v1, v2) end

-------------------------------------------------------------------------------
-- VectorSystem — tabela retornada por require("vectors")
-------------------------------------------------------------------------------

---@class VectorSystem
---@field Circumference VectorCircumference
local VectorSystem = {}

--- Cria um vetor N-dimensional a partir das coordenadas fornecidas.
---@param ... number
---@return Vector
function VectorSystem.CreateVector(...) end

--- Verifica se o valor é um Vector.
---@param t any
---@return boolean isVector
---@return string typeName
function VectorSystem.IsVector(t) end

--- Cria um vetor de dimensão `n` com todos os componentes iguais a `value`.
---@param dimentions integer
---@param value number
---@return Vector
function VectorSystem.CreateConstVector(dimentions, value) end

--- Cria um vetor nulo (todos os componentes = 0) de dimensão `n`.
---@param n integer
---@return Vector
function VectorSystem.CreateVectorZero(n) end

--- Cria um vetor unitário (todos os componentes = 1) de dimensão `n`.
---@param n integer
---@return Vector
function VectorSystem.CreateVectorOne(n) end

return VectorSystem
