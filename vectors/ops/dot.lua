


return function(VectorSystem)
    local ops = {}
    
    ops.Dot = function(v1, v2)
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end

        local d = 0

        v1:OnRun(function(id, value) d = d + value * v2[id] end)

        return d
    end

    return ops
end