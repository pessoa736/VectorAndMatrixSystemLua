
local unpack = table.unpack

return function(MatrixSystem)
    local ops = {}
    
    ops.map = function(m, funct)
        local NewMatrix = {}
        local cols, rows = m.ncols, m.nrows

        if type(funct) == "function" then        
            for idx = 1, rows*cols do
                local pos = {
                    ((idx-1)//cols) + 1,
                    ((idx-1)%cols) + 1
                }
                
                local currentValue = m[pos]
                
                NewMatrix[idx] = funct({i=pos[1], j=pos[2]}, currentValue) or currentValue
            end
        else
            error("expected a function")
        end

        return MatrixSystem.CreateMatrix(rows, cols).data(unpack(NewMatrix)) 
    end

    return ops
end