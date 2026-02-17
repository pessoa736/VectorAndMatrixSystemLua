

---@param MatrixSystem MatrixSystem
---@return table
return function(MatrixSystem)
    local ops = {}

    ---@param m1 Matrix
    ---@param m2 Matrix
    ---@return Matrix
    ops.__add = function(m1, m2)
        if not m1:isCompatibleForSum(m2) then
            error("Matrices must have the same dimensions for addition.")
        end

        -- percorre toda a matrix e soma cada item da mesma posição da outra matrix
        return m1:map(function(pos, currentValue) return currentValue + m2[pos] end)
    end

    -- subtração
    ---@param m1 Matrix
    ---@param m2 Matrix
    ---@return Matrix
    ops.__sub = function(m1, m2)
        if not m1:isCompatibleForSum(m2) then
            error("Matrices must have the same dimensions for addition.")
        end
        -- percorre toda a matrix e soma cada item da mesma posição da outra matrix
        return m1:map(function(pos, currentValue) return currentValue - m2[pos] end)
    end

    -- Multiplicação
    ---@param a Matrix|number
    ---@param b Matrix|number
    ---@return Matrix
    ops.__mul = function(a, b)
        local isMA, tyA = MatrixSystem.IsMatrix(a)
        local isMB, tyB = MatrixSystem.IsMatrix(b)

        if tyA == "number" and isMB then
            ---@cast a number
            ---@cast b Matrix
            return b:map(function (_, currentValue) return a * currentValue end) 

        elseif tyB == "number" and isMA then
            ---@cast a Matrix
            ---@cast b number
            return a:map(function (_, currentValue) return b * currentValue end) 

        elseif isMA and  isMB then
            ---@cast a Matrix
            ---@cast b Matrix
            
            -- Multiplicação de matrizes
            if not a:isCompatibleForMult(b) then
                error("Dimensões incompatíveis para multiplicação de matrizes. Matriz A tem " .. a.ncols .. " colunas, mas matriz B tem " .. b.nrows .. " linhas.")
            end

            return MatrixSystem
                .CreateMatrix(b.ncols, a.nrows)
                :map(
                    function(pos)
                        local sum = 0
                        for k = 1, a.ncols do
                            sum = sum + a[{pos.i, k}] * b[{k, pos.j}]
                        end

                        return sum
                    end
                )
        else
            error("Operação de multiplicação não suportada entre os tipos fornecidos.")
        end
    end

    ---@param m Matrix
    ---@return string
    ops.__tostring = function(m)
        local s = ""

        for i = 1, m.nrows do
            s = s .. "| "
            for j = 1, m.ncols do
                s = s .. tostring(m[{i,j}]) .. "\t"
            end
            s = s .. "|\n"
        end

        return s
    end
    
    ---@param m1 Matrix|any
    ---@param v any
    ---@return string
    ops.__concat = function (m1, v)
        return tostring(m1) .. tostring(v)
    end

    return ops
end