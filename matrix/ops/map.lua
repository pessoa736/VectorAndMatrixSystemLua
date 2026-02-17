
local unpack = table.unpack

---@param MatrixSystem MatrixSystem
---@return table
return function(MatrixSystem)
    local ops = {}
    
    --- Aplica uma função a cada elemento e retorna uma nova matriz
    ---@param m Matrix
    ---@param funct fun(pos: MatrixPos, currentValue: number): number?
    ---@return Matrix
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