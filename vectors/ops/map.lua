
local unpack = table.unpack

return function(VectorSystem)
    local ops = table.create(0,1)

    ops.map = function(v1, fun)
        local rep = table.create(v1.Dimensions)
        for i=1, v1.Dimensions do
            rep[i] = fun(i, v1[i]) or v1[i]
        end

        return VectorSystem.CreateVector(unpack(rep))
    end

    return ops
end