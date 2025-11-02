
return function (VectorSystem)
    local ops = {}
    
    function ops.__add(v1, v2)
        local check = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end

        return v1:map(
            function(dim, currentValue)
                return currentValue + v2[dim]
            end
        )
    end

    function ops.__unm(v1)
        return v1:map(
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
    
    ops.__len = function(s)
        return s.Dimensions
    end

    ops.checkEquipollence = function(s, otherVector)
        if not VectorSystem.IsVector(otherVector) then error(otherVector .. " is not a vector") end

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

        local is1 = VectorSystem.IsVector(v1)
        local is2 = VectorSystem.IsVector(v2)
        
        if is1 and is2 then
            return v1:Dot(v2)
        
        elseif (type(v2) == "number" and is1)  then
            return v1:map(function(_, v) return v * v2 end)
        elseif (type(v1) =="number" and is2) then
            return v2:map(function(_, v) return v * v1 end)
        else
            error("It is not possible to multiply a vector by ".. type(v2))
        end
    end

    return ops
end