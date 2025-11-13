
return function(MatrixSystem)
    local ops = {}
    
    ops.map = function(m, funct)
        local NewMatrix = {}
        if type(funct) == "function" then        
            for row = 1, m.nrows do
                NewMatrix[row] = {}
                for col = 1, m.ncols do
                    local currentValue = m[{row,col}]                        
                    NewMatrix[row][col] = funct(row, col, currentValue)

                end
            end
        else
            error("expected a function")
        end

        return MatrixSystem.TransformInMatrix(NewMatrix)
    end

    return ops
end