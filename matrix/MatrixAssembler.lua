---@version 5.4

local unpack = table.unpack

---@param MatrixPropieties table
---@return MatrixSystem
local function Assembler(MatrixPropieties)
  ---@type MatrixSystem
  local Matrix = {}
  
  --- Cria uma matriz nr × nc. Use `.data(...)` para preencher.
  ---@param nr integer
  ---@param nc integer
  ---@return Matrix
  function Matrix.CreateMatrix(nr, nc)

    if nr+nc <= 1 then error("there are not matrix 0x0") end

    local m = {} ---@diagnostic disable-line: missing-fields
    m.nrows = nr
    m.ncols = nc
    m.type = "matrix"

    m.data = setmetatable(
      {}, 
      {
        __call=function(s, ...) 
          m.data={...} 
          return m 
        end
      }
    )
    
    return setmetatable(m, MatrixPropieties)
  end

  --- Cria uma matriz-coluna (1 × n) a partir dos valores
  ---@param ... number
  ---@return Matrix
  function Matrix.CreateColumnMatrix(...)
    local items = {...}
    local ni = #items
    
    return Matrix
      .CreateMatrix(1, ni)
      .data(unpack(items))
  end

  --- Cria uma matriz-linha (n × 1) a partir dos valores
  ---@param ... number
  ---@return Matrix
  function Matrix.CreateRowMatrix(...)
    local items = {...}
    local ni = #items
    
    return Matrix
      .CreateMatrix(ni, 1)
      .data(unpack(items))
  end

  --- Cria uma matriz nula (todos zeros) de dimensão nr × nc
  ---@param NumRows integer
  ---@param NumCols integer
  ---@return Matrix
  function Matrix.CreateNullMatrix(NumRows, NumCols)
    local m = {}
    
    for i = 1, NumCols*NumRows do
      m[i]=0
    end
    
    return Matrix
      .CreateMatrix(NumRows, NumCols)
      .data(unpack(m))
  end


  --- Verifica se o valor é uma Matrix
  ---@param m1 any
  ---@return boolean isMatrix
  ---@return string typeName
  function Matrix.IsMatrix(m1)
    if type(m1)=="table" then
        return m1.type == "matrix", "matrix"
    else
        return false, type(m1)
    end
  end

  return Matrix
end


return Assembler