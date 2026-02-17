

---@param VectorSystem VectorSystem
---@return table
return function(VectorSystem)
    local ISV = VectorSystem.IsVector
    local ops = {}

    --- Verifica se dois vetores são equipolentes (mesma dimensão)
    ---@param s Vector
    ---@param otherVector Vector
    ---@return boolean equipollent
    ---@return integer dimensions
    ops.checkEquipollence = function(s, otherVector)
        if not ISV(otherVector) then error(otherVector .. " is not a vector") end

        return s.Dimensions == otherVector.Dimensions, s.Dimensions
    end

    


    return ops
end