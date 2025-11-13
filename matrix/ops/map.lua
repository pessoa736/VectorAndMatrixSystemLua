
return function(MatrixSystem)
    local ops = {}
    
    ops.map = function(m, funct)
        if type(funct) == "function" then        
            for row = 1, m.nrows do
                for col = 1, m.ncols do
                    
                    local currentValue = m[{row,col}]                        
                    m[{row, col}] = funct(row, col, currentValue)

                end
            end
        else
            error("expected a function")
        end

        return m
    end

    return ops
end