package.path = package.path .. ";./../?/init.lua"
local vs = require("vectorsSystem")


function check(desc, shouldError, fn)
    print("\n\t" .. (shouldError and " - " or " + ") .. desc .. ":")
    local status, err = pcall(fn)
    if err then print("\t".. err) end
    print("\t" .. ((status ~= shouldError) and "(CORRECT)" or "(THIS IS NOT CORRECT)"))
    print("\n")
end


print("note:\n\t '-' -> means it is supposed to throw an error \n\t '+' -> means it should NOT throw an error ")

print("\n\ntests:")

check("create a vector with no dimensions", true,
    function()
        local v1 = vs.CreateVector()
        print(v1)
    end
)

check("create a vector with N dimensions", false,
    function()
        local v1 = vs.CreateVector(1)
        local v2 = vs.CreateVector(5, 2)
        local v3 = vs.CreateVector(3,2,1)
        local v4 = vs.CreateVector(9,8,7,6)
        local vN = vs.CreateVector(10,20,30,2,4,1,5,23,23,4)
        print("\t"..v1)
        print("\t"..v2)
        print("\t"..v3)
        print("\t"..v4) 
        print("\t"..vN)
    end
)

check("check if three vectors is equipollents", false,
    function()
        local v1 = vs.CreateVector(1, 3, 2)
        local v2 = vs.CreateVector(4, 5, 9)
        local v3 = vs.CreateVector(3,2)

        print("\t" .. v1 .. " and " .. v2 .. " are equipollents?")
        print("\t" .. tostring(v1:checkEquipollence(v2)).."\n")

        print("\t" .. v1 .. " and " .. v3 .. " are equipollents?")
        print("\t" .. tostring(v1:checkEquipollence(v3)).."\n")

        print("\t" .. v2 .. " and " .. v3 .. " are equipollents?")
        print("\t" .. tostring(v2:checkEquipollence(v3)))

    end
)

check("check if it is equipotent between a vector and a not vector", true,
    function() 
        vs.CreateVector(2, 3):checkEquipollence(2)
    end
)

check("check vectors sum", false,
    function()
        local va = vs.CreateVector(0, 2, 5)
        local vb = vs.CreateVector(9, 7, 3)
        local VSum = va + vb

        print("\t"..va)
        print("\t"..vb)
        print("\t"..VSum)
    end
)

check("unary minus negates vector", false,
    function()
        local v = vs.CreateVector(1, -2, 3)
        local vn = -v
        print("\t"..v)
        print("\t"..vn)
    end
)

check("vector subtraction", false,
    function()
        local va = vs.CreateVector(7, 5, 1)
        local vb = vs.CreateVector(2, 9, -3)
        local vsub = va - vb
        print("\t"..va)
        print("\t"..vb)
        print("\t"..vsub)
    end
)

check("change_value updates a coordinate", false,
    function()
        local v = vs.CreateVector(1, 2, 3)
        v:change_value(2, 42)
        print("\t"..v)
    end
)

check("string concatenation with vectors", false,
    function()
        local v = vs.CreateVector(1, 2)
        print("\t" .. ("v = " .. v))
        print("\t" .. (v .. " is cool"))
    end
)

check("transformInVector from table", false,
    function()
        local v = vs.transformInVector({3, 3, 3})
        print("\t"..v)
    end
)

check("transformInVector from function", false,
    function()
        local v = vs.transformInVector(function() return {1, 4, 9} end)
        print("\t"..v)
    end
)

check("sum vectors with different dimensions should error", true,
    function()
        local a = vs.CreateVector(1, 2)
        local b = vs.CreateVector(1, 2, 3)
        local c = a + b
        print(c)
    end
)

check("CreateVector with non-number should error", true,
    function()
        vs.CreateVector(1, "x", 3)
    end
)

check("transformInVector with invalid input should error", true,
    function()
        vs.transformInVector(123)
    end
)

check("checkEquipollence with plain table should error", true,
    function()
        vs.CreateVector(1, 2):checkEquipollence({})
    end
)

check("numeric indexing returns coordinates", false,
    function()
        local v = vs.CreateVector(10, 20, 30)
        print("\t", v[1], v[2], v[3])
    end
)


