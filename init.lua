local VectorSystem = {
    nameLib = "VectorSystem",
    description = "A simple vector system for handling vectors of arbitrary dimensions.",
}

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
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("those vectors is a not equipollents") end

        return v1 + (-v2)
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

-- Allow numeric indexing to access point coordinates (e.g., v[1])
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

return VectorSystem