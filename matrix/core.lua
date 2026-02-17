
---@type table
local Properties = {}

---@param s Matrix
---@param k table|integer|string
---@return any
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

--- Permite escrita usando m[{i,j}] = valor ou m[k] (linear) = valor
---@param s Matrix
---@param k table|integer|string
---@param v any
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

--- Registra operações na metatabela compartilhada
---@param prop fun(system: MatrixSystem): table
local function addProperties(prop)
    for k, v in pairs(prop(MatrixSystem)) do
        rawset(Properties, k, v)
    end
end

-- Cria o MatrixSystem para que os ops possam referenciá-lo
---@type MatrixSystem
MatrixSystem = require("matrix.MatrixAssembler")(Properties)

-- Registra operações na metatabela
addProperties(require("matrix.ops.check"))
addProperties(require("matrix.ops.map"))
addProperties(require("matrix.ops.common"))
addProperties(require("matrix.ops.check"))
addProperties(require("matrix.ops.submatrix"))
addProperties(require("matrix.ops.determinat"))
addProperties(require("matrix.ops.translation"))

---@type MatrixSystem
return MatrixSystem