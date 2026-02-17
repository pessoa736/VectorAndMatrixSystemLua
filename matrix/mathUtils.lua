--- Verifica se o valor é numérico
---@param x any
---@return boolean
local function isnum(x) return type(x) == "number" end

--- Converte o valor para string
---@param x any
---@return string
local function tostr(x) return tostring(x) end

--- Verifica se a string contém + ou - (precisa de parênteses)
---@param s string
---@return boolean
local function needParens(s) return s:find("[%+%-]") ~= nil end

--- Multiplicação simbólica/numérica
---@param a number|string
---@param b number|string
---@return number|string
local function mul(a, b)
    if isnum(a) and isnum(b) then
        return a * b
    end
    local sa, sb = tostr(a), tostr(b)

    if isnum(a) and a == 1 then return sb end
    if isnum(b) and b == 1 then return sa end
    if isnum(a) and a == -1 then
        if sb:sub(1,1) == "-" then return sb:sub(2) end
        if needParens(sb) then sb = "(" .. sb .. ")" end
        return "-" .. sb
    end
    if isnum(b) and b == -1 then
        if sa:sub(1,1) == "-" then return sa:sub(2) end
        if needParens(sa) then sa = "(" .. sa .. ")" end
        return "-" .. sa
    end

    if not isnum(a) and needParens(sa) then sa = "(" .. sa .. ")" end
    if not isnum(b) and needParens(sb) then sb = "(" .. sb .. ")" end
    return sa .. "*" .. sb
end

--- Determinante simbólico estendido (retorna expressão string ou número)
---@param mm Matrix
---@return number|string
local function extDet( mm)
    local m = mm.data
    local m1 = m[1]
    local n = #m

    if n == 1 then
        return m1[1]
    end

    local numericSum = 0
    local parts = {}

    for j = 1, n do
        local sign = ((j % 2 == 0) and -1 or 1)
        local a1j = m1[j]
        local sub = mm:submatrix(1, j)
        local subdet = extDet(sub)

        local term = mul(sign, mul(a1j, subdet))

        if isnum(term) then
            numericSum = numericSum + term
        else
            parts[#parts+1] = term
        end
    end

    if #parts == 0 then
        return numericSum
    else
        local expr = ""
        if numericSum ~= 0 then expr = tostr(numericSum) end
        for _, p in ipairs(parts) do
            if p:sub(1,1) == "-" then
                expr = (expr == "") and p or (expr .. " " .. p)
            else
                expr = (expr == "") and p or (expr .. " + " .. p)
            end
        end
        return expr
    end
end

---@type MathUtils
return {isnum = isnum, tostr = tostr, needParens = needParens, mul = mul, extDet = extDet}