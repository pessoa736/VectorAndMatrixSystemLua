
local pi = math.pi

return function(VectorSystem)
    local ISV = VectorSystem.IsVector
    local ops = {}

    ops.Circumference = setmetatable({}, {__call=function (...)
        return ops.Circumference.getRadius(...)
    end}) 
    
    ops.Circumference.getRadius = function(v1, v2)
        local IS1 = ISV(v1)
        local IS2 = ISV(v2)
        if IS1 then error("argument 1# not are Vector") end
        if IS2 then error("argument 2# not are Vector") end
        
        local dis = v1 - v2
        local radius = dis * dis


        return  radius
    end
    
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