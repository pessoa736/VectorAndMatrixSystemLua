

return function(VectorSystem)
    local ISV = VectorSystem.IsVector
    local ops = {}

    
    ops.checkEquipollence = function(s, otherVector)
        if not ISV(otherVector) then error(otherVector .. " is not a vector") end

        return s.Dimensions == otherVector.Dimensions, s.Dimensions
    end

    


    return ops
end