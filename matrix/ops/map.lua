
return function(MatrixSystem)
    local ops = {}
    
    ops.map = function(m, funct)
        local NewMatrix = {}
        if type(funct) == "function" then        
            for itens = 1, m.nrows*m.ncols do
              local row = (itens-1)%m.nrows +1
              local col = (itens//m.nrows-1) % m.ncols +1
              local currentValue = m[{row,col}] 
               NewMatrix[itens] = funct(row, col, currentValue)
            end
        else
            error("expected a function")
        end

        return MatrixSystem.CreateMatrix(m.nrows, m.ncols, NewMatrix)
    end

    return ops
end