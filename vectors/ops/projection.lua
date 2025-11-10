

return function(VectorSystem)
    local ISV = VectorSystem.IsVector
    local ops = {}

    ops.projection = function(v1, v2)
        local IS1 = ISV(v1)
        local IS2 = ISV(v2)
        
        local size 
        if IS1 and IS2 then size = ((v2 * v1)/(v1 * v1)) end

        local IS3 = ISV(size)
        if IS3 then error("unexpected error") end

        return  size * v1
    end

    return ops
end