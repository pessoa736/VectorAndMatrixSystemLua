package.path = package.path .. ";./../?/init.lua"
local ms = require("matrix")

function check(desc, shouldError, fn)
    print("\n\t" .. (shouldError and " - " or " + ") .. desc .. ":")
    local status, err = pcall(fn)
    if err then print("\t".. err) end
    print("\t" .. ((status ~= shouldError) and "(CORRECT)" or "(THIS IS NOT CORRECT)"))
    print("\n")
end

print("note:\n\t '-' -> means it is supposed to throw an error \n\t '+' -> means it should NOT throw an error ")

print("\n\ntests:")

check("create a matrix with no rows", true,
    function()
        local m1 = ms.createMatriz()
        print(m1)
    end
)

check("create a matrix with multiple rows", false,
    function()
        local m = ms.createMatriz({1, 2, 3}, {4, 5, 6})
        print("\t" .. tostring(m))
    end
)

check("create matrix with non-table row should error", true,
    function()
        local m = ms.createMatriz({1, 2}, 3)
        print(m)
    end
)

check("getItem returns the expected value", false,
    function()
        local m = ms.createMatriz({7, 8}, {9, 10})
        print("\t" .. m:getItem(2, 1))
    end
)

check("getItem outside bounds should error", true,
    function()
        local m = ms.createMatriz({7, 8}, {9, 10})
        print(m:getItem(3, 1))
    end
)

check("modifyItem updates the matrix", false,
    function()
        local m = ms.createMatriz({1, 1}, {1, 1})
        m:modifyItem(1, 2, 99)
        print("\t" .. tostring(m))
    end
)

check("modifyItem outside bounds should error", true,
    function()
        local m = ms.createMatriz({1, 1}, {1, 1})
        m:modifyItem(3, 1, 10)
    end
)

check("map applies a function to every element", false,
    function()
        local m = ms.createMatriz({1, 2}, {3, 4})
        m:map(function(row, col, value)
            return value * (row + col)
        end)
        print("\t" .. tostring(m))
    end
)

check("map with non-function should error", true,
    function()
        local m = ms.createMatriz({1, 2}, {3, 4})
        m:map("not a function")
    end
)

check("transformInMatrix from table", false,
    function()
        local m = ms.transformInMatrix({{5, 5}, {6, 6}})
        print("\t" .. tostring(m))
    end
)

check("transformInMatrix from function", false,
    function()
        local m = ms.transformInMatrix(function()
            return {
                {1, 0},
                {0, 1}
            }
        end)
        print("\t" .. tostring(m))
    end
)

check("transformInMatrix with invalid input should error", true,
    function()
        ms.transformInMatrix(42)
    end
)

check("numeric indexing returns matrix rows", false,
    function()
        local m = ms.createMatriz({11, 12}, {13, 14})
        local firstRow = m[1]
        print("\t" .. table.concat(firstRow, ", "))
    end
)
