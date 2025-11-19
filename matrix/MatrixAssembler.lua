

local unpack = table.unpack


local function Assembler(MatrixPropieties)
  local Matrix = {}
  
  function Matrix.CreateMatrix(nr, nc, ...)
    local args = {...}
    if type(args[1])== "table" then args=args[1] end
    local n = #args

    if n == 0 then error("there are not matrix 0x0") end
    --for k, s in ipairs(args) do print(k, s) end
    local m = {
        nrows = nr,
        ncols = nc,
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



  function Matrix.CreateColumnMatrix(...)
    local items = {...}
    local ni = #items
    return Matrix.CreateMatrix(1, ni, items)
  end

  function Matrix.CreateRowMatrix(...)
    local items = {...}
    local ni = #items
    return Matrix.CreateMatrix(ni, 1, items)
  end

  function Matrix.CreateNullMatrix(NumRows, NumCols)
    local m = {}
    
    for i = 1, NumRows*NumCols do
      m[i]=0
    end
    
    return Matrix.CreateMatrix(NumRows, NumCols, m)
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