
local properties = {} 

local VectorSystem = require("vectors.vectorAssembler")(properties)

local function addProperties(prop)
    for k, v in pairs(prop(VectorSystem)) do
        properties[k] = v 
    end
    
end


addProperties(require("vectors.ops.dot"))
addProperties(require("vectors.ops.common"))
addProperties(require("vectors.ops.cross"))
addProperties(require("vectors.ops.projection"))


properties.__index = function(s, k)
    if type(k) == "number" then
        return s.points[k]
    end
    return properties[k]
end


VectorSystem = require("vectors.vectorAssembler")(properties)

return VectorSystem