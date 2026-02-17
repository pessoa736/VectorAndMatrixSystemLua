
local pi = math.pi

---@param VectorSystem VectorSystem
---@return table
return function(VectorSystem)
    local ISV = VectorSystem.IsVector
    local ops = {}

    ---@type VectorCircumference
    ops.Circumference = setmetatable({}, {__call=function (...)
        return ops.Circumference.getRadius(...)
    end}) 
    
    --- Calcula o raio (distância ao quadrado) entre dois vetores
    ---@param v1 Vector
    ---@param v2 Vector
    ---@return number
    ops.Circumference.getRadius = function(v1, v2)
        local IS1 = ISV(v1)
        local IS2 = ISV(v2)
        if IS1 then error("argument 1# not are Vector") end
        if IS2 then error("argument 2# not are Vector") end
        
        local dis = v1 - v2
        local radius = dis * dis


        return  radius
    end
    
    --- Calcula o perímetro da circunferência entre dois vetores
    ---@param v1 Vector
    ---@param v2 Vector
    ---@return number
    ops.Circumference.getPerimeter = function(v1, v2)
        local IS1 = ISV(v1)
        local IS2 = ISV(v2)
        if IS1 then error("argument 1# not are Vector") end
        if IS2 then error("argument 2# not are Vector") end
        
        local dis = v1 - v2
        local radius = dis * dis

        return  2*radius * pi
    end

    


    return ops
end