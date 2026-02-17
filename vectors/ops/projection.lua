

---@param VectorSystem VectorSystem
---@return table
return function(VectorSystem)
    local IsVector = VectorSystem.IsVector
    local ops = {}

    --- Projeção de v2 sobre v1
    ---@param v1 Vector
    ---@param v2 Vector
    ---@return Vector
    ops.projection = function(v1, v2)
        
        local size 
        if IsVector(v2) and IsVector(v1) then 
            size = ((v2 * v1)/(v1 * v1)) 
        end

        if IsVector(size) then error("unexpected error") end

        return  size * v1
    end

    return ops
end