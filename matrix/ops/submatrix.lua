

return function(MatrixSystem)
  local ops = {}
  
  ops.submatrix = function(m1, row, col)
    local m = m1.data
    local nrows = m1.nrows
    local ncols = m1.ncols
    
    local sub = {}
    for i = 1, nrows  do
        if i ~= row then
            local new_row = {}
            for j = 1, ncols do
                if j ~= col then
                    table.insert(new_row, m1[{i, j}])
                end
            end
            table.insert(sub, new_row)
        end
    end
    return MatrixSystem.TransformInMatrix(sub)
  end
  
  return ops
end