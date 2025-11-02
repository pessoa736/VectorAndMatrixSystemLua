

return function(VectorSystem)
    local ops = {}

    function ops.Cross(v1,...)
        local vectors = {v1, ...}
        if #vectors == 0 then error("expected at least one vector") end

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


        local firstLine = {}
        for j = 1, n do
            firstLine[j] = string.char(96 + j)
        end

        local rows = { firstLine }
        for i = 1, #vectors do
            rows[#rows+1] = vectors[i].points
        end
        
        local M = require("matrix").transformInMatrix(rows)
        local det = M:ExtendDeterminant()

        local coeffs = require("vectors.utils.parseCoefficients")(det, n)
        return VectorSystem.transformInVector(coeffs)
    end




    
    function ops.CrossProduct_2D_or_3D(...)
        local vectors = {...}
        if #vectors == 0 then error("expected at least one vector") end

        local n = vectors[1].Dimensions
        
        if n>3 then error("function does not support vectors with dimension > 3") end

        for i = 2, #vectors do
            local ok = vectors[1]:checkEquipollence(vectors[i])
            if not ok then error("vectors are not equipollent") end
        end
        
        if #vectors ~= n - 1 then
            error("for cross product in R^" .. n .. " you need " .. (n - 1) .. " vectors")
        end

        
        local firstLine = {}
        for j = 1, n do
            firstLine[j] = 1
        end

        local rows = { firstLine }
        for i = 1, #vectors do
            rows[#rows+1] = vectors[i].points
        end


        local Vec = {}
        local M = require("matrix").transformInMatrix(rows)
        M:map(
            function(i, j, C_value)
                if i == 1 then
                    local sum = 0
                    local mult1, mult2 = 1, 1

                    for k = 0, M.ncols-1 do
                        local value1 = M[{i+k,j+k}]
                        local value2 = M[{i+k,j-k}]
                       
                        if value2 ~= C_value then
                            mult2 = mult2 * value2
                        end 
                       
                        if value1 ~= C_value then
                            mult1 = mult1 * value1
                        end
                    end

                    sum = sum + mult1 - mult2
                    Vec[j] = sum
                end
                return C_value 
            end
        )

        return VectorSystem.transformInVector(Vec)
    end
    return ops
end