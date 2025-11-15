
if not log then log = require("loglua") end


local MatrixSystem = {}
local MatrixProperties = {

    getItem = function(m, row, col)
        if row < 1 or row > m.nrows or col < 1 or col > m.ncols then
            error("matrix index out of bounds")
        end
        return m.data[row][col]
    end,

    modifyItem = function(m, row, col, value)
        if row < 1 or row > m.nrows or col < 1 or col > m.ncols then
            error("matrix index out of bounds")
        end

        m.data[row][col] = value or 0

        return m
    end,

    __tostring = function(m)
        local s = ""

        for i = 1, m.nrows do
            s = s .. "| "
            for j = 1, m.ncols do
                s = s .. m.data[i][j] .. "\t"
            end
            s = s .. "|\n"
        end

        return s
    end,


    

    
    ,
    
}









return MatrixSystem;

--[[ daqui para baixo é a versão antiga


function Matriz.__sub(a, b)

    if a.nrows ~= b.nrows or a.ncols ~= b.ncols then
        error("As matrizes devem ter as mesmas dimensões para subtração.")
    end

    local result = Matriz.new(a.nrows, a.ncols,
        function(i, j)
            return a.data[i][j] - b.data[i][j]
        end
    )

    setmetatable(result, Matriz)
    return result
end




function Matriz.__mul(a, b)

    if type(a) == "number" and type(b) == "table" and b.data then

        -- Multiplicação escalar: número * matriz
        local result = Matriz.new(b.nrows, b.ncols,
            function(i, j)
                return a * b.data[i][j]
            end
        )
        setmetatable(result, Matriz)
        return result

    elseif type(b) == "number" and type(a) == "table" and a.data then

        -- Multiplicação escalar: matriz * número
        local result = Matriz.new(a.nrows, a.ncols,
            function(i, j)
                return a.data[i][j] * b
            end
        )

        setmetatable(result, Matriz)
        return result

    elseif type(a) == "table" and type(b) == "table" and a.data and b.data then
        
        -- Multiplicação de matrizes
        if a.ncols ~= b.nrows then
            error("Dimensões incompatíveis para multiplicação de matrizes. Matriz A tem " .. a.ncols .. " colunas, mas matriz B tem " .. b.nrows .. " linhas.")
        end

        local result = Matriz.new(a.nrows, b.ncols,
            function(i, j)
                local sum = 0
                for k = 1, a.ncols do
                    sum = sum + a.data[i][k] * b.data[k][j]
                end
                return sum
            end
        )

        setmetatable(result, Matriz)
        return result
    else
        error("Operação de multiplicação não suportada entre os tipos fornecidos.")
    end
end


function Matriz.__div(a, b)

    if type(a) == "table" and type(b) == "number" then
        local _b = (1 / b)
        return a * _b

    elseif type(b) == "table" then
        ---- daqui para baixo ainda em modificação
        local _b = Matriz.modify(b, function(i, j, value)
            if value == 0 then
                error("Divisão de inversos por zero na posição (" .. i .. ", " .. j .. ")")
            end
            return 1 / value
        end)

        return _b * a

    else
        error("Divisão de matrizes não suportada.")
    end
end



function Matriz.__idiv(a, b)
    local m = a / b

    return m:modify(function(i, j, value)
        return math.floor(value)
    end)
end

function Matriz.__unm(m)
    return m:modify(function(i, j, value)
        return -value
    end)
end

function Matriz.__eq(a, b)

    if a.nrows ~= b.nrows or a.ncols ~= b.ncols then
        return false
    end

    local result

    Matriz.map(a, function(i, j, value)
        result = value == b.data[i][j]
    end)

    return result
end

function Matriz.transpose(self)
    local result = Matriz.new(self.ncols, self.nrows,
        function(i, j)
            return self.data[j][i]
        end
    )
    return result
end

-- Adicionar métodos estáticos para criação especial
function Matriz.identity(n)
    local m = Matriz.new(n, n,
        function(i, j)
            return i == j and 1 or 0
        end
    )
    return m
end

function Matriz.zeros(rows, cols)
    return Matriz.new(rows, cols or rows, 0)
end

function Matriz.ones(rows, cols)
    return Matriz.new(rows, cols or rows, 1)
end

-- Método para obter dimensões
function Matriz.size(m)
    return m.nrows, m.ncols
end

-- Verificação se a matriz é quadrada
function Matriz.isSquare(m)
    return m.nrows == m.ncols
end


-- Retorna a diagonal principal como uma lista
function Matriz.diagonalPrincipal(m)
    local diag = {}
    local n = math.min(m.nrows, m.ncols)
    for i = 1, n do
        diag[#diag+1] = m.data[i][i]
    end
    return diag
end

-- Retorna a diagonal secundária como uma lista
function Matriz.diagonalSecundaria(m)
    local diag = {}
    local n = math.min(m.nrows, m.ncols)
    for i = 1, n do
        diag[#diag+1] = m.data[i][n - i + 1]
    end
    return diag
end


return Matriz]]