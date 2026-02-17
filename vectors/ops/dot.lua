


---@param VectorSystem VectorSystem
---@return table
return function(VectorSystem)
    local IsVector = VectorSystem.IsVector
    local ops = {}
    
    --- Produto escalar entre dois vetores, ou multiplicação escalar
    ---@param v1 Vector|number
    ---@param v2 Vector|number
    ---@return number|Vector
    ops.Dot = function(v1, v2)
        local Is1, type1 = IsVector(v1)
        local Is2, type2 = IsVector(v2)
        if Is1 and Is2 then
            ---@cast v1 Vector
            ---@cast v2 Vector
            if not  v1:checkEquipollence(v2) then error("vectors are not equipollent") end

            local d = 0

            v1:map(function(id, value) d = d + value * v2[id] end)

            return d
        elseif type1 == "number" then
            ---@cast v1 number
            ---@cast v2 Vector
            return v2:map(function(_, value) return value * v1 end)
        elseif type2 == "number" then
            ---@cast v2 number
            ---@cast v1 Vector
            return v1:map(function(_, value) return value * v2 end)
        else 
            error("The operation could not be completed.")
        end
        
    end

    return ops
end