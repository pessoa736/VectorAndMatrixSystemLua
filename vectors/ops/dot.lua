


return function(VectorSystem)
    local IsVector = VectorSystem.IsVector
    local ops = {}
    
    ops.Dot = function(v1, v2)
        local Is1, type1 = IsVector(v1)
        local Is2, type2 = IsVector(v2)
        if Is1 and Is2 then
            if not  v1:checkEquipollence(v2) then error("vectors are not equipollent") end

            local d = 0

            v1:map(function(id, value) d = d + value * v2[id] end)

            return d
        elseif type1 == "number" then
            return v2:map(function(_, value) return value * v1 end)
        elseif type2 == "number" then
            return v1:map(function(_, value) return value * v2 end)
        else 
            error("The operation could not be completed.")
        end
        
    end

    return ops
end