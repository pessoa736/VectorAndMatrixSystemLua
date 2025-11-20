
local Properties = {}

Properties.__index = function(s, k)
    local t = type(k)
    if t == "table" then
        local r = ((k[1] or k.i)-1)%s.nrows + 1
        local c = ((k[2] or k.j)-1)%s.ncols + 1
        return s.data[(r-1)*s.ncols + c]
    elseif  t == "number" then
        return s.data[k]
    else
        return Properties[k]
    end
end

-- Permite escrita usando m[{i,j}] = valor ou m[k] (linear) = valor
Properties.__newindex = function(s, k, v)
    local t = type(k)
    if t == "table" then
        local r = k[1] or k.i
        local c = k[2] or k.j
       s.data[(r-1)*s.ncols + c] = v
    elseif t == "number" then
        s.data[k] = v
    else
        rawset(Properties, k, v)
    end
end

-- Forward declaration so addProperties can capture it as an upvalue
--local MatrixSystem

local function addProperties(prop)
    for k, v in pairs(prop(MatrixSystem)) do
        rawset(Properties, k, v)
    end
end

-- Create the MatrixSystem first so ops can reference it
MatrixSystem = require("matrix.MatrixAssembler")(Properties)

-- Attach operations to the metatable
addProperties(require("matrix.ops.check"))
addProperties(require("matrix.ops.map"))
addProperties(require("matrix.ops.common"))
addProperties(require("matrix.ops.check"))
addProperties(require("matrix.ops.submatrix"))
addProperties(require("matrix.ops.determinat"))
addProperties(require("matrix.ops.translation"))

return MatrixSystem