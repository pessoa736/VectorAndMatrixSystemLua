
local unpack = table.unpack

return function(VectorSystem)
    local ops = {}

    ops.map = function(v1, fun)
        local rep={}
        for i=1, v1.Dimensions do
            local currentValue = v1[i]
            rep[i] = fun(i, currentValue) or currentValue
        end

        return VectorSystem.CreateVector(unpack(rep))
    end

    return ops
end