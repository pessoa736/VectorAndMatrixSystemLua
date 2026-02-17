
local unpack = table.unpack

---@param VectorSystem VectorSystem
---@return table
return function(VectorSystem)
    local ops = {}

    --- Aplica uma função a cada componente e retorna um novo vetor
    ---@param v1 Vector
    ---@param fun fun(dim: integer, value: number): number?
    ---@return Vector
    ops.map = function(v1, fun)
        local rep = {}
        for i=1, v1.Dimensions do
            rep[i] = fun(i, v1[i]) or v1[i]
        end

        return VectorSystem.CreateVector(unpack(rep))
    end

    return ops
end