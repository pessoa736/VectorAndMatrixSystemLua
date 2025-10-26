
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

    map = function(m, funct)
        if type(funct) == "function" then        
            for row = 1, m.nrows do
                for col = 1, m.ncols do
                    
                    local currentValue = m.data[row][col]                        
                    m.data[row][col] = funct(row, col, currentValue)

                end
            end
        else 
            error("expected a function")
        end

        return m
    end,

    isCompatibleForMult = function(m1, m2)
        if not MatrixSystem.isMatrix(m2) then error(tostring(m2) .. " is not a matrix") end
        return m1.ncols == m2.nrows 
    end,

    isCompatibleForSum = function(m1, m2)
        if not MatrixSystem.isMatrix(m2) then error(tostring(m2) .. " is not a matrix") end
        return m1.ncols == m2.ncols and m1.nrows == m2.nrows 
    end,

    isSquare = function(m1)
        if not MatrixSystem.isMatrix(m1) then error("provided value is not a matrix") end
        return m1.ncols == m1.nrows
    end,

    __add = function(m1, m2)
        if not m1:isCompatibleForSum(m2) then
            error("Matrices must have the same dimensions for addition.")
        end

        m1:map(function(row, col, currentValue)
            return currentValue + m2:getItem(row, col)
        end)

        return m1
    end,

    submatrix = function(m1, row, col)
        local m = m1.data
        local sub = {}
        for i = 1, #m do
            if i ~= row then
                local new_row = {}
                for j = 1, #m[i] do
                    if j ~= col then
                        table.insert(new_row, m[i][j])
                    end
                end
                table.insert(sub, new_row)
            end
        end
        sub = MatrixSystem.transformInMatrix(sub)
        return sub
    end,

    determinant = function (m1)
        local m = m1.data
        local n = #m

        if n == 1 then 
            return 
                m[1][1] 
        end
        if n == 2 then 
            return 
                m[1][1] * m[2][2] - 
                m[1][2] * m[2][1] 
        end
        if n == 3 then return 
            m[1][1] * (m[2][2]*m[3][3] - m[2][3]*m[3][2]) + 
            m[1][2] * (m[2][3]*m[3][1] - m[2][1]*m[3][3]) + 
            m[1][3] * (m[2][1]*m[3][2] - m[2][2]*m[3][1])
        end
        
        local det = 0
        for j = 1, n do
            local sign = ((j % 2 == 0) and -1 or 1)
            local sub = m1:submatrix(1, j)
            det = det + sign * m[1][j] * sub:determinant()
        end

        return det
    end,
    ExtendDeterminant = function(m1)
        local function isnum(x) return type(x) == "number" end
        local function tostr(x) return tostring(x) end
        local function needParens(s) return s:find("[%+%-]") ~= nil end

        local function mul(a, b)
            if isnum(a) and isnum(b) then
                return a * b
            end
            local sa, sb = tostr(a), tostr(b)

            if isnum(a) and a == 1 then return sb end
            if isnum(b) and b == 1 then return sa end
            if isnum(a) and a == -1 then
                if sb:sub(1,1) == "-" then return sb:sub(2) end
                if needParens(sb) then sb = "(" .. sb .. ")" end
                return "-" .. sb
            end
            if isnum(b) and b == -1 then
                if sa:sub(1,1) == "-" then return sa:sub(2) end
                if needParens(sa) then sa = "(" .. sa .. ")" end
                return "-" .. sa
            end

            if not isnum(a) and needParens(sa) then sa = "(" .. sa .. ")" end
            if not isnum(b) and needParens(sb) then sb = "(" .. sb .. ")" end
            return sa .. "*" .. sb
        end

        local function extDet(mm)
            local m = mm.data
            local n = #m

            if n == 1 then
                return m[1][1]
            end

            local numericSum = 0
            local parts = {}

            for j = 1, n do
                local sign = ((j % 2 == 0) and -1 or 1)
                local a1j = m[1][j]
                local sub = mm:submatrix(1, j)
                local subdet = extDet(sub)

                local term = mul(sign, mul(a1j, subdet))

                if isnum(term) then
                    numericSum = numericSum + term
                else
                    parts[#parts+1] = term
                end
            end

            if #parts == 0 then
                return numericSum
            else
                local expr = ""
                if numericSum ~= 0 then expr = tostr(numericSum) end
                for _, p in ipairs(parts) do
                    if p:sub(1,1) == "-" then
                        expr = (expr == "") and p or (expr .. " " .. p)
                    else
                        expr = (expr == "") and p or (expr .. " + " .. p)
                    end
                end
                return expr
            end
        end

        return extDet(m1)
    end
}

MatrixProperties.__index = function(s, k)
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
        return MatrixProperties[k]
    end
end




function MatrixSystem.createMatriz(...)
    local args = {...}

    if #args == 0 then error("there is no matrix 0x0") end

    local errors = ""
    for k, v in ipairs(args) do
        if type(v) ~= "table" then 
            errors = errors  .. k ..  (k == #args and "" or (k == #args - 1 and " and " or ", "))
        end
    end
    if #errors > 0 then error("the lines " .. errors .. " are not lines") end

    local m = {
        nrows = #args,
        ncols = #args[1],
        data = args,
        type = "matrix"
    }
    
    return setmetatable(m, MatrixProperties)
end




function MatrixSystem.transformInMatrix(t)
    if type(t)=="table" then
        return MatrixSystem.createMatriz(table.unpack(t)) 
        
    elseif type(t)=="function" then  
        return MatrixSystem.createMatriz(table.unpack(t())) 
    else
        error("expected a table or function in this function")
    end
    
end

function MatrixSystem.isMatrix(m1)
    if type(m1)=="table" then
        return m1.type == "matrix" 
    else
        return false
    end
end

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