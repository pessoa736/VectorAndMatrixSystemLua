
return function (VectorSystem)
    local ops = {}
    
    function ops.__add(v1, v2)
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end

        return v1:map(
            function(dim, currentValue)
                return currentValue + v2[dim]
            end
        )
    end

    function ops.__unm(v1)
        v1:map(
            function(_, currentValue)
                return -currentValue 
            end
        )   
    end

    function ops.__sub(v1, v2)
        if not v1:checkEquipollence(v2) then error("vectors are not equipollent") end

        return v1 + (-v2)
    end

    function ops.map(s, fun)
        local vector = {}
        for i= 1, s.Dimensions do
            local currentValue = s[i]
             vector[i] = fun(i, currentValue)
        end
        return VectorSystem.transformInVector(vector)
    end

    ops.OnRun = function(s,fun)
        for i= 1, s.Dimensions do
            fun(i, s[i])
        end
    end

    ops.dot = function(v1, v2)
        local check, dim = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end

        local d = 0
        for i=1, dim do
            d = d + v1[i]*v2[i] 
        end

        return d
    end
    
    ops.__len = function(s)
        return s.Dimensions
    end

    ops.checkEquipollence = function(s, otherVector)
        if type(otherVector)~="table" then error(otherVector .. " is not a vector") 
        elseif (not otherVector.Dimensions) and otherVector.type~="vector" then error(otherVector .. " is not a vector")  end

        return s.Dimensions == otherVector.Dimensions, s.Dimensions
    end

    ops.change_value = function(s, dimension, new_value)
        if dimension>0 and dimension<= #s.points then 
            s.points[dimension] = new_value
        end
    end

    ops.__tostring = function(s)
        local result = 'Vector' .. s.Dimensions .. ":{"

        for k, v in ipairs(s.points) do
            result = result .. " " .. v .. (k==#s.points and " " or ", ")
        end

        return result .. "}"
    end

    ops.__concat = function(s, v)
        return tostring(s) .. tostring(v)        
    end

    ops.__mul = function (v1, v2)
        return ops.dot(v1, v2)
    end

    return ops
end