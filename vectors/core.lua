---@type table
local properties = {} 


---@param s Vector
---@param k integer|string
---@return any
properties.__index = function(s, k)
    if type(k) == "number" then
        return s.points[k]
    end
    return properties[k]
end

properties.__newindex = function(s, k, v)
    if type(k) == "number" then
        s.points[k] = v
    end
    properties[k] = v
end


---@type VectorSystem
local VectorSystem = require("vectors.vectorAssembler")(properties)

--- Registra operações na metatabela compartilhada
---@param prop fun(system: VectorSystem): table
local function addProperties(prop)
    for k, v in pairs(prop(VectorSystem)) do
        properties[k] = v
    end
    
end


local files ={
    "vectors.ops.dot",
    "vectors.ops.common",
    "vectors.ops.cross",
    "vectors.ops.projection",
    "vectors.ops.map",
    "vectors.ops.checks"
}

for k, file in ipairs(files) do
    addProperties(require(file))
end





---@type VectorSystem
VectorSystem = require("vectors.vectorAssembler")(properties)

---@type VectorSystem
return VectorSystem