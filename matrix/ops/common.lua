

return function(MatrixSystem)
    local ops = {}

    ops.__add = function(m1, m2)
        if not m1:isCompatibleForSum(m2) then
            error("Matrices must have the same dimensions for addition.")
        end

        -- percorre toda a matrix e soma cada item da mesma posição da outra matrix
        return m1:map(function(row, col, currentValue) return currentValue + m2[{row, col}] end)
    end

    -- subtração
    ops.__sub = function(m1, m2)
        if not m1:isCompatibleForSum(m2) then
            error("Matrices must have the same dimensions for addition.")
        end
        -- percorre toda a matrix e soma cada item da mesma posição da outra matrix
        return m1:map(function(row, col, currentValue) return currentValue - m2[{row, col}] end)
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
            if not a:isCompatibleForMult(b) then
                error("Dimensões incompatíveis para multiplicação de matrizes. Matriz A tem " .. a.ncols .. " colunas, mas matriz B tem " .. b.nrows .. " linhas.")
            end
            local m = MatrixSystem.CreateNullMatrix(b.ncols, a.nrows)
            return m:map(function(i, j, currentValue)
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

    ops.__tostring = function(m)
        local s = ""

        for i = 1, m.nrows do
            s = s .. "| "
            for j = 1, m.ncols do
                s = s .. m[{i,j}] .. "\t"
            end
            s = s .. "|\n"
        end

        return s
    end
    
    ops.__concat = function (m1, v)
        return tostring(m1) .. tostring(v)
    end

    return ops
end