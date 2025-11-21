local unpack = table.unpack

return function(MatrixSystem)
  local ops = {}
  
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