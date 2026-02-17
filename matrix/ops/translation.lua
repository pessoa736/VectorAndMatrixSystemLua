local unpack = table.unpack

---@param MatrixSystem MatrixSystem
---@return table
return function(MatrixSystem)
  local ops = {}
  
  --- Retorna a transposta da matriz
  ---@param m1 Matrix
  ---@return Matrix
  ops.T = function(m1)
    local nrows = m1.nrows
    local ncols = m1.ncols
    
    return MatrixSystem.CreateMatrix(ncols, nrows):map(
        function (pos, currentValue)
            return m1[{pos.j, pos.i}]
        end
    )
  end
  
  return ops
end