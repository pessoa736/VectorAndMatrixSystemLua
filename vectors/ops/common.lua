
---@param VectorSystem VectorSystem
---@return table
return function (VectorSystem)
    local ops = {}
    
    ---@param v1 Vector
    ---@param v2 Vector
    ---@return Vector
    function ops.__add(v1, v2)
        local check = v1:checkEquipollence(v2)
        if not check then error("vectors are not equipollent") end
        return v1:map(function(dim, currentValue) return currentValue + v2[dim] end)
    end

    ---@param v1 Vector
    ---@return Vector
    function ops.__unm(v1) 
        return v1:map(function(_, currentValue) return -currentValue end) 
    end

    ---@param v1 Vector
    ---@param v2 Vector
    ---@return Vector
    function ops.__sub(v1, v2)
        if not v1:checkEquipollence(v2) then error("vectors are not equipollent") end

        return v1:map(function(dim, currentValue) return currentValue - v2[dim] end)
    end

    ---@param s Vector
    ---@return integer
    ops.__len = function(s) return s.Dimensions end


    ---@param s Vector
    ---@return string
    ops.__tostring = function(s)
        local result = 'Vector' .. s.Dimensions .. ":{"

        for k, v in ipairs(s.points) do
            result = result .. " " .. v .. (k==#s.points and " " or ", ")
        end

        return result .. "}"
    end

    ---@param s Vector|any
    ---@param v any
    ---@return string
    ops.__concat = function(s, v)
        return tostring(s) .. tostring(v)        
    end

    ---@param v1 Vector|number
    ---@param v2 Vector|number
    ---@return number|Vector
    ops.__mul = function (v1, v2)

        local is1 = VectorSystem.IsVector(v1)
        local is2 = VectorSystem.IsVector(v2)
        
        if is1 then
            ---@cast v1 Vector
            return v1:Dot(v2)
        else
            ---@cast v2 Vector
            return v2:Dot(v1)
        end
    end

    return ops
end