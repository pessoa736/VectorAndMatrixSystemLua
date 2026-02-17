
local unpack = table.unpack

---@param VectorSystem VectorSystem
---@return table
return function(VectorSystem)
    local Mat = require("matrix.core").CreateMatrix
    local CreateVector = VectorSystem.CreateVector
    local ops = {}

    --- Produto vetorial generalizado em R^n
    ---@param v1 Vector
    ---@param ... Vector
    ---@return Vector
    function ops.Cross(v1, ...)
        local vectors = {v1, ...}
        if #vectors < 1 then error("expected at least one vector") end

        local n = vectors[1].Dimensions
        
        if n==3 or n==2 then
            return v1:CrossProduct_2D_or_3D(...)
        end
        
        for i = 2, #vectors do
            local ok = vectors[1]:checkEquipollence(vectors[i])
            if not ok then error("vectors are not equipollent") end
        end
        if #vectors ~= n - 1 then
            error("for cross product in R^" .. n .. " you need " .. (n - 1) .. " vectors")
        end


        -- Generalized cross product in R^n: components are cofactors of the (n-1)x n matrix
        -- formed by the given vectors (each vector is a row). We avoid symbolic determinants.
        local baseRows = {}
        for i = 1, #vectors do
            baseRows[i] = vectors[i].points
        end

        local function minor(rows, skipCol)
            local m = {}
            for r = 1, #rows do
                local newRow = {}
                for c = 1, #rows[r] do
                    if c ~= skipCol then
                        newRow[#newRow+1] = rows[r][c]
                    end
                end
                m[#m+1] = newRow
            end
            return m
        end

        local function det(rows)
            local sz = #rows
            if sz == 1 then return rows[1][1] end
            if sz == 2 then
                local r1, r2 = rows[1], rows[2]
                return r1[1]*r2[2] - r1[2]*r2[1]
            end
            local d = 0
            local first = rows[1]
            for j = 1, sz do
                local sign = (j % 2 == 1) and 1 or -1
                local sub = {}
                for r = 2, sz do
                    local newRow = {}
                    for c = 1, sz do
                        if c ~= j then newRow[#newRow+1] = rows[r][c] end
                    end
                    sub[#sub+1] = newRow
                end
                d = d + sign * first[j] * det(sub)
            end
            return d
        end

        local result = {}
        for col = 1, n do
            local sign = (col % 2 == 1) and 1 or -1  -- (-1)^{col+1}
            local m = minor(baseRows, col)
            result[col] = sign * det(m)
        end
        return CreateVector(unpack(result))
    end




    --- Produto vetorial otimizado para 2D e 3D
    ---@param v1 Vector
    ---@param ... Vector
    ---@return Vector
    function ops.CrossProduct_2D_or_3D(v1, ...)
        local vectors = {v1, ...}
        local Nvectors = #vectors
        if Nvectors == 0 then error("expected at least one vector") end

        local n = v1.Dimensions
        
        if n>3 then error("function does not support vectors with dimension > 3") end

        for i = 2, Nvectors do
            local ok = v1:checkEquipollence(vectors[i])
            if not ok then error("vectors are not equipollent") end
        end
        
        if Nvectors ~= n - 1 then
            error("for cross product in R^" .. n .. " you need " .. (n - 1) .. " vectors")
        end

        
        if n == 2 then
            local v = v1
            if Nvectors ~= 1 then
                error("for cross product in R^2 you need 1 vector (self only)")
            end
            return CreateVector(-v[2], v[1])
        elseif n == 3 then
            if Nvectors ~= 2 then
                error("for cross product in R^3 you need 2 vectors (self and one more)")
            end
            local a, b = v1, vectors[2]
            return CreateVector(
                a[2]*b[3] - a[3]*b[2],
                a[3]*b[1] - a[1]*b[3],
                a[1]*b[2] - a[2]*b[1]
            )
        end
        error("unexpected dimension for 2D/3D helper")
    end
    return ops
end