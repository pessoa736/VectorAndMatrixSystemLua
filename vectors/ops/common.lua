
return function (VectorSystem)
    local ops = {}
    
    function ops.__add(v1, v2)
        local check = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end
        return v1:map(function(dim, currentValue) return currentValue + v2[dim] end)
    end

    function ops.__unm(v1) 
        return v1:map(function(_, currentValue) return -currentValue end) 
    end

    function ops.__sub(v1, v2)
        if not v1:checkEquipollence(v2) then error("vectors are not equipollent") end

        return v1:map(function(dim, currentValue) return currentValue - v2[dim] end)
    end

    ops.__len = function(s) return s.Dimensions end


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
        
        if is1 then  return v1:Dot(v2) else
        v2:Dot(v1) end
    end

    return ops
end