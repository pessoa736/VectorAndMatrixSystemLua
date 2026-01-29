
return function (expr, n)
    if type(expr) ~= "string" then expr = tostring(expr or "") end

    expr = expr:gsub("%s+", "")
    local len = #expr
    local pos = 1

    local coeffs = table.create(n)
    for i = 1, n do coeffs[i] = 0 end

    local function add(sym, num, sign)
        if not sym then return end
        local ch = sym:sub(1, 1):lower()
        local idx = string.byte(ch) - 96
        if idx < 1 or idx > n then return end
        local coef = tonumber(num or "1") or 1
        if sign == "-" then coef = -coef end
        coeffs[idx] = coeffs[idx] + coef
    end

    local function try(pat)
        local s, e, a, b = expr:find(pat, pos)
        if s == pos then return e, a, b end
    end

    while pos <= len do
        local sign = "+"
        local c = expr:sub(pos, pos)
        if c == "+" or c == "-" then
            sign = c
            pos = pos + 1
            if pos > len then break end
        end

        local e, a, b
        e, a, b = try("([%a]+)%*%((%-?%d+%.?%d*)%)")
        if e then add(a, b, sign); pos = e + 1; goto continue end

        e, a, b = try("([%a]+)%*(%-?%d+%.?%d*)")
        if e then add(a, b, sign); pos = e + 1; goto continue end

        e, a, b = try("(%-?%d+%.?%d*)%*([%a]+)")
        if e then add(b, a, sign); pos = e + 1; goto continue end

        e, a, b = try("([%a]+)(%-?%d+%.?%d*)")
        if e then add(a, b, sign); pos = e + 1; goto continue end

        e, a, b = try("(%-?%d+%.?%d*)([%a]+)")
        if e then add(b, a, sign); pos = e + 1; goto continue end

        e, a = try("([%a]+)")
        if e then add(a, "1", sign); pos = e + 1; goto continue end

        pos = pos + 1
        ::continue::
    end

    return coeffs
end