local MS
package.path = package.path .. ";./../?/init.lua"
MS = require("matrix")


local VectorSystem = {}

local VectorProperties = {

    __add = function(v1, v2)
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end

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
                    result[i] = -s[i]
                end
                return result
            end
        )        
    end,

    __sub = function(v1, v2)
        if not v1:checkEquipollence(v2) then error("vectors are not equipollent") end

        return v1 + (-v2)
    end,

    map = function(s, fun)
        local vector = {}
        for i= 1, s.Dimensions do
            local currentValue = s[i]
             vector[i] = fun(i, currentValue)
        end
        return VectorSystem.transformInVector(vector)
    end,

    OnRun = function(s,fun)
        for i= 1, s.Dimensions do
            fun(i, s[i])
        end
    end,

    CrossNProduct = function(v1,...)
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

        local function extractCoefficientsToVector(expr, n)
            if type(expr) ~= "string" then expr = tostring(expr or "") end

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
                local sign = "+"
                local c = expr:sub(pos, pos)
                if c == "+" or c == "-" then
                    sign = c
                    pos = pos + 1
                    if pos > len then break end
                end

                local e, a, b

                e, a, b = try("([%a]+)%*%((%-?%d+%.?%d*)%)")
                if e then add(a, b, sign); pos = e + 1; goto continue end

                e, a, b = try("([%a]+)%*(%-?%d+%.?%d*)")
                if e then add(a, b, sign); pos = e + 1; goto continue end

                e, a, b = try("(%-?%d+%.?%d*)%*([%a]+)")
                if e then add(b, a, sign); pos = e + 1; goto continue end

                e, a, b = try("([%a]+)(%-?%d+%.?%d*)")
                if e then add(a, b, sign); pos = e + 1; goto continue end

                e, a, b = try("(%-?%d+%.?%d*)([%a]+)")
                if e then add(b, a, sign); pos = e + 1; goto continue end

                e, a = try("([%a]+)")
                if e then add(a, "1", sign); pos = e + 1; goto continue end

                pos = pos + 1
                ::continue::
            end

            return coeffs
        end


        local firstLine = {}
        for j = 1, n do
            firstLine[j] = string.char(96 + j)
        end

        local rows = { firstLine }
        for i = 1, #vectors do
            rows[#rows+1] = vectors[i].points
        end
        
        local M = MS.transformInMatrix(rows)
        local det = M:ExtendDeterminant()

        local coeffs = extractCoefficientsToVector(det, n)
        return VectorSystem.transformInVector(coeffs)
    end,

    CrossProduct_2D_or_3D = function(...)
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
        local M = MS.transformInMatrix(rows)
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
    end,

    dot = function(v1, v2)
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end

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
        if type(otherVector)~="table" then error(otherVector .. " is not a vector") 
        elseif (not otherVector.Dimensions) and otherVector.type~="vector" then error(otherVector .. " is not a vector")  end

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

function VectorSystem.CreateConstVector(dimentions, value)
    local dimentions = dimentions or 1
    local value = value or 0

    if dimentions< 1 then error("It is not possible to create a vector with a dimension smaller than 1") end

    return VectorSystem.transformInVector(
        function ()
            local v = {}
            for i=1, dimentions do
                v[i] = value
            end
            return v
        end
    )    
end

function VectorSystem.CreateVectorZero(n)
    return VectorSystem.CreateConstVector(n, 0)
end

function VectorSystem.CreateVectorOne(n)
    return VectorSystem.CreateConstVector(n, 1)
end

return VectorSystem