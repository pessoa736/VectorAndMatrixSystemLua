local unpack = table.unpack

return function(MatrixSystem)
  local ops = {}
  
  ops.submatrix = function(m1, row, col)
    local m = m1.data
    local nrows = m1.nrows
    local ncols = m1.ncols
    
    local sub = {}
    for idx = 1, nrows*ncols  do
        local i = (idx-1)//ncols+1
        local j = (idx-1)%ncols+1 

        if i ~= row and j ~= col then
            table.insert(sub, m1[{i, j}])
        end
    end
    return MatrixSystem.CreateMatrix(nrows-1, ncols-1).data(unpack(sub))
  end
  
  return ops
end