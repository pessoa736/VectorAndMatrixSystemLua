---@meta

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
-- VectorSystem — tabela retornada por require("vectors")
-------------------------------------------------------------------------------

---@class VectorSystem
---@field Circumference? VectorCircumference
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
-- Matrix
-------------------------------------------------------------------------------

---@class Matrix
---@field nrows integer               Número de linhas
---@field ncols integer               Número de colunas
---@field type "matrix"               Discriminador de tipo
---@field data number[]               Dados armazenados linearmente (row-major)
---@operator add(Matrix): Matrix
---@operator sub(Matrix): Matrix
---@operator mul(number): Matrix
---@operator mul(Matrix): Matrix
---@operator concat(any): string
local Matrix = {}

--- Aplica uma função a cada elemento e retorna uma nova matriz.
---@param funct fun(pos: MatrixPos, currentValue: number): number?
---@return Matrix
function Matrix:map(funct) end

--- Verifica se as dimensões são compatíveis para soma.
---@param m2 Matrix
---@return boolean
function Matrix:isCompatibleForSum(m2) end

--- Verifica se as dimensões são compatíveis para multiplicação.
---@param m2 Matrix
---@return boolean
function Matrix:isCompatibleForMult(m2) end

--- Verifica se a matriz é quadrada.
---@return boolean
function Matrix:isSquare() end

--- Extrai uma submatriz removendo a linha `row` e a coluna `col`.
---@param row integer
---@param col integer
---@return Matrix
function Matrix:submatrix(row, col) end

--- Calcula o determinante da matriz (deve ser quadrada).
---@return number
function Matrix:determinant() end

--- Calcula o determinante simbólico estendido.
---@return number|string
function Matrix:ExtendDeterminant() end

--- Retorna a transposta da matriz.
---@return Matrix
function Matrix:T() end

-------------------------------------------------------------------------------
-- MatrixPos — posição passada para callbacks de map
-------------------------------------------------------------------------------

---@class MatrixPos
---@field i integer  linha (1-based)
---@field j integer  coluna (1-based)

-------------------------------------------------------------------------------
-- MatrixSystem — tabela retornada por require("matrix")
-------------------------------------------------------------------------------

---@class MatrixSystem
local MatrixSystem = {}

--- Cria uma matriz de dimensão `nr × nc`. Use `.data(...)` para preencher.
---@param nr integer
---@param nc integer
---@return Matrix
function MatrixSystem.CreateMatrix(nr, nc) end

--- Cria uma matriz-coluna (1 × n) a partir dos valores.
---@param ... number
---@return Matrix
function MatrixSystem.CreateColumnMatrix(...) end

--- Cria uma matriz-linha (n × 1) a partir dos valores.
---@param ... number
---@return Matrix
function MatrixSystem.CreateRowMatrix(...) end

--- Cria uma matriz nula (todos zeros) de dimensão `nr × nc`.
---@param NumRows integer
---@param NumCols integer
---@return Matrix
function MatrixSystem.CreateNullMatrix(NumRows, NumCols) end

--- Verifica se o valor é uma Matrix.
---@param m1 any
---@return boolean isMatrix
---@return string typeName
function MatrixSystem.IsMatrix(m1) end

-------------------------------------------------------------------------------
-- MathUtils
-------------------------------------------------------------------------------

---@class MathUtils
---@field isnum fun(x: any): boolean
---@field tostr fun(x: any): string
---@field needParens fun(s: string): boolean
---@field mul fun(a: number|string, b: number|string): number|string
---@field extDet fun(mm: Matrix): number|string

-------------------------------------------------------------------------------
-- parseCoefficients
-------------------------------------------------------------------------------

--- Extrai coeficientes de uma expressão algébrica em variáveis a..z.
---@param expr string|any  expressão a ser parseada
---@param n integer         número de variáveis (1=a, 2=a,b, …)
---@return number[]         coeficientes indexados de 1 a n
local function parseCoefficients(expr, n) end
