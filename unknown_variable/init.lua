local unknownSystem = {}

local unkProperties = {
    __add = function(a, b)
        if a.name == b.name then  
            return unknownSystem.createUnk(a.name, b.GeometricScale + a.GeometricScale)
        else 
            return a, b
        end
    end,
    __sub = function(a, b)
        if a.name == b.name then  
            return unknownSystem.createUnk(a.name, a.GeometricScale - b.GeometricScale)
        else 
            return a, b
        end
    end,
    __mul = function(a, b)
        if a.name == b.name then  
            return unknownSystem.createUnk(a.name, b.GeometricScale * a.GeometricScale)
        else 
            return unknownSystem.createUnk(a.name .. b.name, )
        end
    end,
}

unkProperties.__index = function(s, k)
    return unkProperties[k]
end

function unknownSystem.createUnk(name, scale)
    local unk = {
        name = name or "x",
        type = "unknown_var",
        GeometricScale = scale or 1,
    }

    return setmetatable(unk, unkProperties)
end

-- function unknownSystem.createUnkGroup(name)
--     local unk = {
--         name = name or "G",
--         type = "unknown_var_group",
--         operantion = "",
--         vars = {}
--     }

--     return setmetatable(unk, unkProperties)
-- end