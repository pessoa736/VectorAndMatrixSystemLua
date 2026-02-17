---@meta matrix
---@module "matrix"

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

return MatrixSystem
