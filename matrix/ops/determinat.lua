
local ut = require("matrix.mathUtils")
local extDet = ut.extDet

return function(MatrixSystem)
    local ops = {}

    ops.determinant=function (selfMatrix)
        local m = selfMatrix.data
        local n = #m

        local m1 = m[1] or 0
        local m2 = m[2] or 0
        local m3 = m[3] or 0

        if n == 1 then
            return
                m1[1]
        end
        if n == 2 then 
            return 
                m1[1] * m2[2] -
                m1[2] * m2[1]
        end
        if n == 3 then return 
            m1[1] * (m2[2]*m3[3] - m2[3]*m3[2]) +
            m1[2] * (m2[3]*m3[1] - m2[1]*m3[3]) +
            m1[3] * (m2[1]*m3[2] - m2[2]*m3[1])
        end
        
        local det = 0
        for j = 1, n do
            local sign = ((j % 2 == 0) and -1 or 1)
            local sub = selfMatrix:submatrix(1, j)
            det = det + sign * m1[j] * sub:determinant()
        end

        return det
    end
    ops.ExtendDeterminant = function(m1)
        return extDet(m1)
    end

    return ops
end