local MS
if package.loaded["matrix"] == nil then
    package.path = package.path .. ";./../?/init.lua"
    MS = require("matrix")
end 

local VectorSystem = {}

local VectorProperties = {

    __add = function(v1, v2)
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("those vectors is a not equipollents") end

        return VectorSystem.transformInVector(
            function()
                local sum = {}
                for i= 1, dim do
                    sum[i] = v1[i] + v2[i]
                end
                return sum
            end
        )
    end,

    __unm = function(s)
        return VectorSystem.transformInVector(
            function()
                local result = {}
                for i=1, s.Dimensions do
                    result[i] = -s.points[i]
                end
                return result
            end
        )        
    end,

    __sub = function(v1, v2)
        if not v1:checkEquipollence(v2) then error("those vectors is a not equipollents") end

        return v1 + (-v2)
    end,

    map = function(s, fun)
        local vector = {}
        for i= 1, s.Dimensions do
            local currentValue = s.points[i]
             vector[i] = fun(i, currentValue)
        end
        return VectorSystem.transformInVector(vector)
    end,

    -- CrossNProduct = function(...)
    --     local vectors = {...}

    --     local firstLine = {}
    --     for i=1, #vectors+1 do
    --         firstLine[i] = string.char(i)
    --     end

    --     local det = MS.createMatriz(firstLine, unpack(vectors)):ExtendDeterminant()

    -- end,

    CrossNProduct = function(...)
        local vectors = {...}
        if #vectors == 0 then error("esperado pelo menos 1 vetor") end

        local n = vectors[1].Dimensions
        for i = 2, #vectors do
            local ok = vectors[1]:checkEquipollence(vectors[i])
            if not ok then error("vetores não equipolentes") end
        end
        if #vectors ~= n - 1 then
            error("para produto vetorial em R^" .. n .. " são necessários " .. (n - 1) .. " vetores")
        end

        local function extractCoefficientsToVector(expr, n)
            if type(expr) ~= "string" then expr = tostring(expr or "") end

            -- remove espaços
            expr = expr:gsub("%s+", "")
            local len = #expr
            local pos = 1

            local coeffs = {}
            for i = 1, n do coeffs[i] = 0 end

            local function add(sym, num, sign)
                if not sym then return end
                local ch = sym:sub(1,1):lower()
                local idx = string.byte(ch) - 96
                if idx < 1 or idx > n then return end
                local coef = tonumber(num or "1") or 1
                if sign == "-" then coef = -coef end
                coeffs[idx] = coeffs[idx] + coef
            end

            local function try(pat)
                local s, e, a, b = expr:find(pat, pos)
                if s == pos then return e, a, b end
            end

            while pos <= len do
                -- lê sinal opcional
                local sign = "+"
                local c = expr:sub(pos, pos)
                if c == "+" or c == "-" then
                    sign = c
                    pos = pos + 1
                    if pos > len then break end
                end

                -- tenta casar padrões a partir de pos (não quebrar '-' interno)
                local e, a, b

                -- s*(num) com parênteses: a*(-30)
                e, a, b = try("([%a]+)%*%((%-?%d+%.?%d*)%)")
                if e then add(a, b, sign); pos = e + 1; goto continue end

                -- s*num: a*-30, a*20
                e, a, b = try("([%a]+)%*(%-?%d+%.?%d*)")
                if e then add(a, b, sign); pos = e + 1; goto continue end

                -- num*s: -30*a, 20*b
                e, a, b = try("(%-?%d+%.?%d*)%*([%a]+)")
                if e then add(b, a, sign); pos = e + 1; goto continue end

                -- s<num>: b-6, c3.5
                e, a, b = try("([%a]+)(%-?%d+%.?%d*)")
                if e then add(a, b, sign); pos = e + 1; goto continue end

                -- num s sem '*': 6b, -6c
                e, a, b = try("(%-?%d+%.?%d*)([%a]+)")
                if e then add(b, a, sign); pos = e + 1; goto continue end

                -- s isolado: a, b, c
                e, a = try("([%a]+)")
                if e then add(a, "1", sign); pos = e + 1; goto continue end

                -- caractere inesperado: evita loop infinito
                pos = pos + 1
                ::continue::
            end

            return coeffs
        end

         -- primeira linha simbólica (apenas rótulos)
        local firstLine = {}
        for j = 1, n do
            firstLine[j] = string.char(96 + j) -- 'a','b','c',...
        end

        -- constrói matriz usando as LINHAS NUMÉRICAS (points), não os objetos Vector
        local rows = { firstLine }
        for i = 1, #vectors do
            rows[#rows+1] = vectors[i].points
        end
        local M = MS.transformInMatrix(rows)
        local det = M:ExtendDeterminant()

        local coeffs = extractCoefficientsToVector(det, n)
        return VectorSystem.transformInVector(coeffs)
    end,

    dot = function(v1, v2)
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("those vectors is a not equipollents") end

        local d = 0
        for i=1, dim do
            d = d + v1[i]*v2[i] 
        end

        return d
    end,
    
    __len = function(s)
        return s.Dimensions
    end,

    checkEquipollence = function(s, otherVector)
        if type(otherVector)~="table" then error(otherVector .. " is a not Vector") 
        elseif (not otherVector.Dimensions) and otherVector.type~="vector" then error(otherVector .. " is a not Vector")  end

        return s.Dimensions == otherVector.Dimensions, s.Dimensions
    end,

    change_value = function(s, dimension, new_value)
        if dimension>0 and dimension<= #s.points then 
            s.points[dimension] = new_value
        end
    end,

    __tostring = function(s)
        local result = 'Vector' .. s.Dimensions .. ":{"

        for k, v in ipairs(s.points) do
            result = result .. " " .. v .. (k==#s.points and " " or ", ")
        end

        return result .. "}"
    end,
    __concat = function(s, v)
        return tostring(s) .. tostring(v)        
    end
}

VectorProperties.__index = function(s, k)
    if type(k) == "number" then
        return s.points[k]
    end
    return VectorProperties[k]
end



function VectorSystem.CreateVector(...)
    local args = {...} 
    if #args == 0 then error("there is no dimensionless vector") end

    local errors = ""
    for k, v in ipairs(args) do
        if type(v) ~= "number" then 
            errors = errors .. '{value=' .. tostring(v) .. ", axis=" .. k .. '}' 
                .. (k == #args and "" or (k == #args - 1 and " and " or ", "))
        end
    end
    if #errors > 0 then error("the points" .. errors .. " are not numbers") end

    local Vector = setmetatable(
        {
            Dimensions = #args,
            type = "vector",
            points = args
        }, 
        VectorProperties 
    )
    

    return Vector
end



function VectorSystem.transformInVector(t)
    if type(t)=="table" then
        return VectorSystem.CreateVector(table.unpack(t)) 
        
    elseif type(t)=="function" then  
        return VectorSystem.CreateVector(table.unpack(t())) 
    else
        error("expected a table or function in this function")
    end
    
end

function VectorSystem.IsVector(t)
    if type(t)=="table" then
        return t.type == "vector" 
    else
        return false
    end
end

return VectorSystem