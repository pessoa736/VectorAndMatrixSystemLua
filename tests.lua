package.path = package.path .. ";./?/init.lua"

local vs = require("vectors")
local ms = require("matrix")
local log = require("loglua")

local numTest = 0
local function check(desc, shouldError, fn)
    
    numTest = numTest + 1
    log()
    log()
    log()
    log( "(" .. numTest .. ")" )
    
    if shouldError then
        log( " -- " .. desc .. ":")
    else
        log(" ++ " .. desc .. ": ")
    end

    local status, err = pcall(fn)
    
    if err then log(err) end

    if shouldError ~= status then 
        log("(".. numTest .. ")" .. "(CORRECT)")
    else
        log.error( "(" .. numTest .. ")" .. "(THIS IS NOT CORRECT)")    
    end
    log()
end


log("note: ")
log("\t'--' -> means it is supposed to throw an error")
log("\t'++' -> means it should NOT throw an error ")
log()
log("tests:")

-- helper to print each operation performed inside tests
local function op(desc, fn)
    log(" > " .. desc )
    log()
    if fn then
        local result = fn()
        if result ~= nil then
            local t = type(result)
            if t == "table" and result.type == "vector" then
                log(" result: " .. tostring(result))
            elseif t == "table" and result.type == "matrix" then
                log(" result: \n\n" .. tostring(result))
            else
                log(" result: " .. tostring(result))
            end
        end
        return result
    end
end

-- vectors: basic construction and properties
check("CreateVector and properties", false, function()
    local v = op("vs.CreateVector(1, 2, 3)", function() return vs.CreateVector(1, 2, 3) end)
    op("check Dimensions, #, and indexing", function()
        assert(v.Dimensions == 3, "Dimensions should be 3")
        assert(#v == 3, "#v should be 3")
        assert(v[1] == 1 and v[2] == 2 and v[3] == 3, "Indexing should return components")
    end)
    op("vs.IsVector(v)", function() return vs.IsVector(v) end)
    op("tostring(v)", function() return tostring(v) end)
end)

check("CreateVector must fail without args", true, function()
    op("vs.CreateVector()", function() return vs.CreateVector() end)
end)

check("CreateVector must fail with non-number entries", true, function()
    op("vs.CreateVector('a', 2)", function() return vs.CreateVector("a", 2) end)
end)

check("CreateConstVector/Zero/One", false, function()
    local v1 = op("vs.CreateConstVector(3, 7)", function() return vs.CreateConstVector(3, 7) end)
    op("assert v1 values", function()
        assert(v1[1] == 7 and v1[2] == 7 and v1[3] == 7)
    end)
    local v0 = op("vs.CreateVectorZero(4)", function() return vs.CreateVectorZero(4) end)
    op("assert v0 values", function()
        for i = 1, 4 do assert(v0[i] == 0) end
    end)
    local vO = op("vs.CreateVectorOne(2)", function() return vs.CreateVectorOne(2) end)
    op("assert vO values", function()
        assert(vO[1] == 1 and vO[2] == 1)
    end)
end)

check("CreateConstVector must fail with dim < 1", true, function()
    op("vs.CreateConstVector(0, 9)", function() return vs.CreateConstVector(0, 9) end)
end)

-- vectors: arithmetic
check("vector addition", false, function()
    local a = op("vs.CreateVector(1,2,3)", function() return vs.CreateVector(1,2,3) end)
    local b = op("vs.CreateVector(4,5,6)", function() return vs.CreateVector(4,5,6) end)
    local c = op("a + b", function() return a + b end)
    op("assert sum components", function()
        assert(c[1] == 5 and c[2] == 7 and c[3] == 9)
    end)
end)

check("vector subtraction", false, function()
    local a = op("vs.CreateVector(5,4,3)", function() return vs.CreateVector(5,4,3) end)
    local b = op("vs.CreateVector(1,2,3)", function() return vs.CreateVector(1,2,3) end)
    local c = op("a - b", function() return a - b end)
    op("assert diff components", function()
        assert(c[1] == 4 and c[2] == 2 and c[3] == 0)
    end)
end)

check("vector unary minus", false, function()
    local a = op("vs.CreateVector(2,-3)", function() return vs.CreateVector(2, -3) end)
    local b = op("-a", function() return -a end)
    op("assert neg components", function()
        assert(b[1] == -2 and b[2] == 3)
    end)
end)

check("vector addition must fail for non-equipollent", true, function()
    local a = op("vs.CreateVector(1,2)", function() return vs.CreateVector(1, 2) end)
    local b = op("vs.CreateVector(1,2,3)", function() return vs.CreateVector(1, 2, 3) end)
    op("a + b (should error)", function() return a + b end)
end)

check("dot product", false, function()
    local a = op("vs.CreateVector(1,3,-5)", function() return vs.CreateVector(1, 3, -5) end)
    local b = op("vs.CreateVector(4,-2,-1)", function() return vs.CreateVector(4, -2, -1) end)
    local d = op("a:dot(b)", function() return a:dot(b) end)
    op("assert dot value", function()
        assert(d == (1*4 + 3*(-2) + -5*(-1)))
    end)
end)

check("checkEquipollence errors on invalid inputs", true, function()
    local a = op("vs.CreateVector(1,2)", function() return vs.CreateVector(1, 2) end)
    op("a:checkEquipollence(5)", function() return a:checkEquipollence(5) end)
end)

check("checkEquipollence errors on table not being a vector", true, function()
    local a = op("vs.CreateVector(1,2)", function() return vs.CreateVector(1, 2) end)
    op("a:checkEquipollence({})", function() return a:checkEquipollence({}) end)
end)

check("map and OnRun", false, function()
    local a = op("vs.CreateVector(1,2,3)", function() return vs.CreateVector(1, 2, 3) end)
    local b = op("a:map(x2)", function() return a:map(function(_, val) return val * 2 end) end)
    op("assert mapped components", function()
        assert(b[1] == 2 and b[2] == 4 and b[3] == 6)
    end)
    local sum = op("b:OnRun(sum)", function()
        local s = 0
        b:OnRun(function(_, val) s = s + val end)
        return s
    end)
    op("assert sum == 12", function() assert(sum == 12) end)
end)

check("transformInVector from table and function", false, function()
    local v1 = op("vs.transformInVector({9,8})", function() return vs.transformInVector({9, 8}) end)
    op("assert v1 components", function() assert(v1[1] == 9 and v1[2] == 8) end)
    local v2 = op("vs.transformInVector(fn->{3,3,3})", function() return vs.transformInVector(function() return {3, 3, 3} end) end)
    op("assert v2 components", function() assert(v2[1] == 3 and v2[3] == 3) end)
end)

check("transformInVector must fail on invalid type", true, function()
    op("vs.transformInVector(123)", function() return vs.transformInVector(123) end)
end)

check("Cross product 3D (2 vectors)", false, function()
    local u = op("vs.CreateVector(1,0,0)", function() return vs.CreateVector(1, 0, 0) end)
    local v = op("vs.CreateVector(0,1,0)", function() return vs.CreateVector(0, 1, 0) end)
    local w = op("u:CrossNProduct(v)", function() return u:CrossNProduct(v) end)
    op("assert cross = k-hat", function()
        assert(w[1] == 0 and w[2] == 0 and w[3] == 1)
    end)
end)

-- vectors: other metamethods
check("__concat produces string", false, function()
    local v = op("vs.CreateVector(1,2)", function() return vs.CreateVector(1, 2) end)
    local s = op("'V=' .. v", function() return "V=" .. v end)
    op("assert string contains Vector2", function()
        assert(type(s) == "string" and s:match("Vector2"))
    end)
end)

-- matrices: construction and basic operations
check("createMatriz and accessors", false, function()
    local m = op("ms.createMatriz({1,2},{3,4})", function() return ms.createMatriz({1,2},{3,4}) end)
    op("assert dims", function() assert(m.nrows == 2 and m.ncols == 2) end)
    op("m:getItem(1,2)", function() return m:getItem(1,2) end)
    op("m[{2,1}]", function() return m[{2,1}] end)
    local wrapped = op("m[3] (numeric index)", function() return m[3] end)
    op("assert numeric index returns number", function() assert(type(wrapped) == "number") end)
    op("m:modifyItem(2,2,10)", function() return m:modifyItem(2,2,10) end)
    op("m:getItem(2,2)", function() return m:getItem(2,2) end)
    op("tostring(m)", function() return tostring(m) end)
end)

check("createMatriz must fail without rows", true, function()
    op("ms.createMatriz()", function() return ms.createMatriz() end)
end)

check("createMatriz must fail when a row is not a table", true, function()
    op("ms.createMatriz({1,2}, 3)", function() return ms.createMatriz({1,2}, 3) end)
end)

check("getItem out of bounds must error", true, function()
    local m = op("ms.createMatriz({1,2},{3,4})", function() return ms.createMatriz({1,2},{3,4}) end)
    op("m:getItem(3,1)", function() return m:getItem(3,1) end)
end)

check("map modifies matrix values", false, function()
    local m = op("ms.createMatriz({1,2},{3,4})", function() return ms.createMatriz({1,2},{3,4}) end)
    op("m:map(x2)", function() return m:map(function(_,_,v) return v*2 end) end)
    op("assert doubled values", function() assert(m:getItem(1,1) == 2 and m:getItem(2,2) == 8) end)
end)

check("submatrix and determinant (numeric)", false, function()
    local m3 = op("ms.createMatriz(3x3)", function() return ms.createMatriz({1,2,3},{0,1,4},{5,6,0}) end)
    local sub = op("m3:submatrix(1,2)", function() return m3:submatrix(1,2) end)
    op("assert sub dims and items", function()
        assert(sub.nrows == 2 and sub.ncols == 2)
        assert(sub:getItem(1,1) == 0 and sub:getItem(1,2) == 4)
    end)
    local d1 = op("determinant of {{5}}", function() return ms.transformInMatrix({{5}}):determinant() end)
    op("assert d1==5", function() assert(d1 == 5) end)
    local d2 = op("determinant of 2x2", function() return ms.transformInMatrix({{1,2},{3,4}}):determinant() end)
    op("assert d2 value", function() assert(d2 == (1*4 - 2*3)) end)
    local d3 = op("m3:determinant()", function() return m3:determinant() end)
    op("assert d3==1", function() assert(d3 == 1) end)
end)

check("ExtendDeterminant (symbolic 2x2)", false, function()
    local m = op("ms.transformInMatrix({{'a','b'},{'c','d'}})", function() return ms.transformInMatrix({{"a","b"},{"c","d"}}) end)
    local expr = op("m:ExtendDeterminant()", function() return m:ExtendDeterminant() end)
    op("assert expr is non-empty string", function() assert(type(expr) == "string" and #expr > 0) end)
end)

check("transformInMatrix from table and function", false, function()
    local m1 = op("ms.transformInMatrix(table)", function() return ms.transformInMatrix({{1,2},{3,4}}) end)
    op("assert m1:getItem(2,1) == 3", function() assert(m1:getItem(2,1) == 3) end)
    local m2 = op("ms.transformInMatrix(function)", function() return ms.transformInMatrix(function() return {{7}} end) end)
    op("assert m2:getItem(1,1) == 7", function() assert(m2:getItem(1,1) == 7) end)
end)

check("transformInMatrix must fail on invalid type", true, function()
    op("ms.transformInMatrix(42)", function() return ms.transformInMatrix(42) end)
end)


log.show()