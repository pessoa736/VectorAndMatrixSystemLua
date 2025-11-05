
return function(VectorSystem)
    local ops = {}

    ops.Circumference = setmetatable({}, {__call=function ()
        
    end}) 
    
    ops.Circumference.getRadius = function(v1, v2)
        local IS1 = VectorSystem.IsVector(v1)
        local IS2 = VectorSystem.IsVector(v2)
        
        local dis = v1 - v2
        local radius = dis * dis


        return  radius
    end
    


    return ops
end