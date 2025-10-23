package.path = package.path .. ";./../?/init.lua"

function check(desc, shouldError, fn)
    print("\n\t" .. (shouldError and " - " or " + ") .. desc .. ":")
    local status, err = pcall(fn)
    if err then print("\t".. err) end
    print("\t" .. ((status ~= shouldError) and "(CORRECT)" or "(THIS IS NOT CORRECT)"))
    print("\n")
end

local vs = require("vectorsSystem")

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

check("check if it is equipotent between a vector and a number", true,
    function() 
        vs.CreateVector(2, 3):checkEquipollence(2)
    end
)
