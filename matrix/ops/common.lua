

return function(MatrixSystem)
    local ops = {}

    ops.__add = function(m1, m2)
        if not m1:isCompatibleForSum(m2) then
            error("Matrices must have the same dimensions for addition.")
        end


        -- percorre toda a matrix e soma cada item da mesma posição da outra matrix
        m1:map(function(row, col, currentValue) return currentValue + m2[{row, col}] end)

        return m1
    end

    -- subtração
    ops.__sub = function(m1, m2)
        if not m1:isCompatibleForSum(m2) then
            error("Matrices must have the same dimensions for addition.")
        end

        -- percorre toda a matrix e soma cada item da mesma posição da outra matrix
        m1:map(function(row, col, currentValue) return currentValue - m2[{row, col}] end)

        return m1
    end

    -- Multiplicação
    ops.__mul = function(a, b)
        local isMA, tyA = MatrixSystem.IsMatrix(a)
        local isMB, tyB = MatrixSystem.IsMatrix(b)

        if tyA == "number" and isMB then
            return b:map(function (i, j, currentValue) return a * currentValue end) 

        elseif tyB == "number" and isMA then
            return a:map(function (i, j, currentValue) return b * currentValue end) 

        elseif isMA and  isMB then
            
            -- Multiplicação de matrizes
            if a.ncols ~= b.nrows then
                error("Dimensões incompatíveis para multiplicação de matrizes. Matriz A tem " .. a.ncols .. " colunas, mas matriz B tem " .. b.nrows .. " linhas.")
            end

            return a:map(function(i, j, currentValue)
                local sum = 0
                for k = 1, a.ncols do
                    sum = sum + a[{i,k}] * b[{k,j}]
                end
                return sum
            end)
        else
            error("Operação de multiplicação não suportada entre os tipos fornecidos.")
        end
    end

    return ops
end