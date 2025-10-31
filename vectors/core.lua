


local properties = {} 

local VectorSystem = require("vectors.vectorAssembler")(properties)

properties = { 
    table.unpack(properties), 
    table.unpack(require("vectors.ops.common")(VectorSystem)), 
    table.unpack(require("vectors.ops.cross")(VectorSystem))
}


return VectorSystem