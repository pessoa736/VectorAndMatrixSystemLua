

local unpack = table.unpack
local function Assembler(MatrixPropieties)
  local Matrix = {}
  
  function Matrix.CreateMatrix(...)
    local args = {...}
    local n = #args

    if n == 0 then error("there are not matrix 0x0") end

    local errors = ""
    for k, v in ipairs(args) do
        if type(v) ~= "table" then 
            errors = errors  .. k ..  (k == n and "" or (k == n - 1 and " and " or ", "))
        end
    end
    if #errors > 0 then error("the lines " .. errors .. " are not lines") end

    local m = {
        nrows = n,
        ncols = #args[1],
        data = args,
        type = "matrix"
    }
    
    return setmetatable(m, MatrixPropieties)
  end
  
  function Matrix.TransformInMatrix(t)
    if type(t)=="table" then
        return Matrix.CreateMatrix(unpack(t)) 
        
    elseif type(t)=="function" then  
        return Matrix.CreateMatrix(unpack(t())) 
    else
        error("expected a table or function in this function")
    end
  end
  
  function Matrix.IsMatrix(m1)
    if type(m1)=="table" then
        return m1.type == "matrix", "matrix"
    else
        return false, type(m1)
    end
  end

  return Matrix
end


return Assembler