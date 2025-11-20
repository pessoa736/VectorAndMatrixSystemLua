

local unpack = table.unpack


local function Assembler(MatrixPropieties)
  local Matrix = {}
  
  function Matrix.CreateMatrix(nr, nc)

    if nr+nc <= 1 then error("there are not matrix 0x0") end
    local m = {
        nrows = nr,
        ncols = nc,
        type = "matrix"
    }
    
    m.data = setmetatable(
      {}, 
      {
        __call=function(s, ...) 
          m.data={...} 
          return m 
        end
      }
    )
    
    return setmetatable(m, MatrixPropieties)
  end

  function Matrix.CreateColumnMatrix(...)
    local items = {...}
    local ni = #items
    
    return Matrix
      .CreateMatrix(1, ni)
      .data(unpack(items))
  end

  function Matrix.CreateRowMatrix(...)
    local items = {...}
    local ni = #items
    
    return Matrix
      .CreateMatrix(ni, 1)
      .data(unpack(items))
  end

  function Matrix.CreateNullMatrix(NumRows, NumCols)
    local m = {}
    
    for i = 1, NumRows*NumCols do
      m[i]=0
    end
    
    return Matrix
      .CreateMatrix(NumRows, NumCols)
      .data(unpack(m))
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