

---@param MatrixSystem MatrixSystem
---@return table
return function(MatrixSystem)
    local ops = {}
    
    --- Verifica se as dimensões são compatíveis para multiplicação
    ---@param m1 Matrix
    ---@param m2 Matrix
    ---@return boolean
    ops.isCompatibleForMult = function(m1, m2)
        if not MatrixSystem.IsMatrix(m2) then error(tostring(m2) .. " is not a matrix") end
        return m1.ncols == m2.nrows
    end

    --- Verifica se as dimensões são compatíveis para soma
    ---@param m1 Matrix
    ---@param m2 Matrix
    ---@return boolean
    ops.isCompatibleForSum = function(m1, m2)
        if not MatrixSystem.IsMatrix(m2) then error(tostring(m2) .. " is not a matrix") end
        return m1.ncols == m2.ncols and m1.nrows == m2.nrows 
    end

    --- Verifica se a matriz é quadrada
    ---@param m1 Matrix
    ---@return boolean
    ops.isSquare = function(m1)
        if not MatrixSystem.IsMatrix(m1) then error("provided value is not a matrix") end
        return m1.ncols == m1.nrows
    end


    return ops
end