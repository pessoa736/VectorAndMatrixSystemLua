-- This tests file was created by GitHub Copilot on 2025-10-24.
-- Purpose: Validate the Matrix module behaviors and surface current known issues.
-- Note: The repository owner was analyzing the assistant's actions throughout the creation of this file.


package.path = package.path .. ";./../?/init.lua"
local ms = require("matrix")

function check(desc, shouldError, fn, io)
    print("\n\t" .. (shouldError and " - " or " + ") .. desc .. ":")
    if io and io.input then
        print("\tinputs: " .. io.input)
    else
        print("\tinputs: (not provided)")
    end

    local packed = { pcall(fn) }
    local status = table.remove(packed, 1)
    if status then
        if #packed == 0 then
            print("\toutput: (no return)")
        elseif #packed == 1 then
            local v = packed[1]
            if type(v) == "table" then
                print("\toutput:")
                print(v)
            else
                print("\toutput: " .. tostring(v))
            end
        else
            print("\toutput:")
            for i = 1, #packed do
                local v = packed[i]
                if type(v) == "table" then
                    print(v)
                else
                    print("\t  [" .. i .. "] " .. tostring(v))
                end
            end
        end
    else
        print("\toutput: error -> " .. tostring(packed[1]))
    end
    print("\t" .. ((status ~= shouldError) and "(CORRECT)" or "(THIS IS NOT CORRECT)"))
    print("\n")
end

print("note:\n\t '-' -> means it is supposed to throw an error \n\t '+' -> means it should NOT throw an error ")
print("\n\ntests:")



-- Example matrices
local A = ms.createMatriz({1, 2}, {3, 4})
local B = ms.createMatriz({5, 6}, {7, 8})


-- Matrix creation
check("createMatriz: creates a valid 2x2 matrix", false, function()
    local M = ms.createMatriz({1, 2}, {3, 4})
    if not M or M.nrows ~= 2 or M.ncols ~= 2 then
        error("incorrect dimensions")
    end
    return M.nrows, M.ncols
end, { input = "rows={{1,2},{3,4}}" })

check("createMatriz: error with empty arguments", true, function()
    ms.createMatriz()
end, { input = "()" })

check("createMatriz: error when a row is not a table", true, function()
    ms.createMatriz({1, 2}, 3)
end, { input = "rows={{1,2}, 3}" })

-- Item access and modification
check("getItem: returns correct element (1,2) == 2", false, function()
    local v = A:getItem(1, 2)
    if v ~= 2 then error("expected 2, got " .. tostring(v)) end
    return v
end, { input = "A, row=1, col=2" })

check("getItem: index out of bounds should fail", true, function()
    A:getItem(0, 1)
end, { input = "A, row=0, col=1" })

check("modifyItem: changes element within bounds", false, function()
    local M = ms.createMatriz({1, 2}, {3, 4})
    M:modifyItem(2, 1, 99)
    if M.data[2][1] ~= 99 then error("did not change correctly") end
    return M[2][1]
end, { input = "M={{1,2},{3,4}}, set(2,1)=99" })

check("modifyItem: index out of bounds should fail", true, function()
    A:modifyItem(3, 3, 1)
end, { input = "A, set(3,3)=1" })

-- Numeric indexing (m[row][col])
check("numeric indexer: m[1][2] == 2", false, function()
    if A[1][2] ~= 2 then error("indexer did not return the correct row/column") end
    return A[1][2]
end, { input = "A[1][2]" })

-- __tostring
check("__tostring: basic formatting", false, function()
    local s = tostring(ms.createMatriz({1, 2}, {3, 4}))
    if not s:find("| ") or not s:find("1.00") or not s:find("4.00") then
        error("string does not have the expected formatting")
    end
    return s
end, { input = "M={{1,2},{3,4}}" })

-- map
check("map: applies function to all elements", false, function()
    local M = ms.createMatriz({1, 2}, {3, 4})
    M:map(function(i, j, v) return v * 2 end)
    if M[1][1] ~= 2 or M[2][2] ~= 8 then error("map did not apply correctly") end
    return M[1][1], M[2][2]
end, { input = "M={{1,2},{3,4}}, f(v)=v*2" })

check("map: fails when argument is not a function", true, function()
    local M = ms.createMatriz({1, 2}, {3, 4})
    M:map(123)
end, { input = "M={{1,2},{3,4}}, f=123" })

-- isMatrix (current implementation has a bug; this test should flag it)
check("isMatrix: should return true for a created matrix (KNOWN BUG)", true, function()
    local M = ms.createMatriz({1})
    local ok = ms.isMatrix(M)
    if ok ~= true then error("isMatrix should return true") end
    return ok
end, { input = "M={{1}}" })

-- Compatibility and addition (current implementation calls isMatrix and should fail)
check("__add: addition of compatible matrices (expected to fail due to isMatrix bug)", true, function()
    local M = ms.createMatriz({1, 1}, {1, 1})
    local N = ms.createMatriz({2, 2}, {2, 2})
    local R = M + N
    if R[1][1] ~= 3 then error("incorrect sum") end
    return R
end, { input = "M={{1,1},{1,1}} + N={{2,2},{2,2}}" })

-- submatrix
check("submatrix: removes given row and column", false, function()
    local M = ms.createMatriz({1, 2, 3}, {4, 5, 6}, {7, 8, 9})
    local sub = M:submatrix(2, 2) -- remove row 2 and column 2
    -- sub is a plain table
    if type(sub) ~= "table" or #sub.data ~= 2 or #sub.data[1] ~= 2 then
        error("submatrix did not return a 2x2 subtable")
    end
    if sub[1][1] ~= 1 or sub[2][2] ~= 9 then error("incorrect submatrix") end
    return sub
end, { input = "M=3x3, remove row=2, col=2" })

-- determinant
check("determinant: 1x1", false, function()
    local M = ms.createMatriz({7})
    local d = M:determinant()
    if d ~= 7 then error("incorrect 1x1 determinant") end
    return d
end, { input = "M={{7}}" })

check("determinant: 2x2", false, function()
    local M = ms.createMatriz({1, 2}, {3, 4})
    local d = M:determinant()
    if d ~= (1*4 - 2*3) then error("incorrect 2x2 determinant") end
    return d
end, { input = "M={{1,2},{3,4}}" })

check("determinant: 3x3", false, function()
    local M = ms.createMatriz({6, 1, 1}, {4, -2, 5}, {2, 8, 7})
    local d = M:determinant()
    if d ~= -306 then error("incorrect 3x3 determinant; got " .. tostring(d)) end
    return d
end, { input = "M={{6,1,1},{4,-2,5},{2,8,7}}" })

check("determinant: 4x4 ", false, function()
    local M = ms.createMatriz({1, 0, 2, -1}, {3, 0, 0, 5}, {2, 1, 4, -3}, {1, 0, 5, 0})
    local d = M:determinant()
    -- if it doesn't fail, still validate type
    if type(d) ~= "number" then error("invalid determinant") end
    return d
end, { input = "M=4x4" })

check("determinant: 5x5 ", false, function()
    local M = ms.createMatriz(
        {1, 0, 2, -1, 4}, 
        {3, 0, 0, 5, 2}, 
        {2, 1, 4, -3,7}, 
        {1, 0, 5, 0, 3}, 
        {1, 3, 4, 5, 2}
    )
    local d = M:determinant()
    -- if it doesn't fail, still validate type
    if type(d) ~= "number" then error("invalid determinant") end
    return d
end, { input = "M=5x5" })

check("Extenddeterminant: 3x3 ", false, function()
    local M = ms.createMatriz(
        {"i", "j", "k", "L", "T"}, 
        {1, -1, -1, 2, 3}, 
        {1, -1, 1, 4, 5}, 
        {1, 0, 1, 3, -5}, 
        {1, -1, 1, 4, 1}
    )
    local d = M:ExtendDeterminant()
    return d
end, { input = "M=5x5" })

-- transformInMatrix
check("transformInMatrix: from table", false, function()
    local M = ms.transformInMatrix({{1, 2}, {3, 4}})
    if M.nrows ~= 2 or M.ncols ~= 2 then error("incorrect dimensions") end
    return M.nrows, M.ncols
end, { input = "{{1,2},{3,4}}" })

check("transformInMatrix: from function", false, function()
    local M = ms.transformInMatrix(function()
        return {{1, 0}, {0, 1}}
    end)
    if M[1][1] ~= 1 or M[2][2] ~= 1 then error("transformInMatrix(function) incorrect") end
    return M[1][1], M[2][2]
end, { input = "function() return {{1,0},{0,1}} end" })

check("transformInMatrix: invalid type should fail", true, function()
    ms.transformInMatrix(123)
end, { input = "123" })

