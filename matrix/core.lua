
local Properties = {}

Properties.__index = function(s, k)
    local t = type(k)
    if t == "table" then
        local r = (k[1]-1)%s.nrows + 1
        local c = (k[2]-1)%s.ncols + 1
        return s.data[r][c]
    elseif  t == "number" then
        local r = (k-1)%s.nrows + 1
        local c = (k-1)%s.ncols + 1
        return s.data[r][c]
    else
        return Properties[k]
    end
end

-- Permite escrita usando m[{i,j}] = valor ou m[k] (linear) = valor
Properties.__newindex = function(s, k, v)
    local t = type(k)
    if t == "table" then
        local r = k[1]
        local c = k[2]

        if not type(s.data[r]) == "table" then s.data[r]={} end
        s.data[r][c] = v
    elseif t == "number" then
        if not type(s.data[k]) == "table" then s.data[k]={} end
        s.data[k][k] = v
    else
        rawset(s, k, v)
    end
end

-- Forward declaration so addProperties can capture it as an upvalue
local MatrixSystem

local function addProperties(prop)
    for k, v in pairs(prop(MatrixSystem)) do
        Properties[k] = v
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

return MatrixSystem