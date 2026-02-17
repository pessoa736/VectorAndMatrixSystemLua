---@meta

-- Definições de tipo compartilhadas do VMSL.
-- As anotações de módulo estão em:
--   types/vectors.lua  →  require("vectors") : VectorSystem
--   types/matrix.lua   →  require("matrix")  : MatrixSystem

-------------------------------------------------------------------------------
-- parseCoefficients
-------------------------------------------------------------------------------

--- Extrai coeficientes de uma expressão algébrica em variáveis a..z.
---@param expr string|any  expressão a ser parseada
---@param n integer         número de variáveis (1=a, 2=a,b, …)
---@return number[]         coeficientes indexados de 1 a n
local function parseCoefficients(expr, n) end
