

---@param VectorProperties table
---@return VectorSystem
local function AssemblerCreate(VectorProperties)
    local Assembler = {}

    --- Cria um vetor N-dimensional a partir das coordenadas
    ---@param ... number
    ---@return Vector
    function Assembler.CreateVector(...)
        local args = {...} 
        if #args == 0 then error("there is no dimensionless vector") end

        local errors = ""
        for k, v in ipairs(args) do
            if type(v) ~= "number" then 
                errors = errors .. '{value=' .. tostring(v) .. ", axis=" .. k .. '}' 
                    .. (k == #args and "" or (k == #args - 1 and " and " or ", "))
            end
        end
        if #errors > 0 then error("the points" .. errors .. " are not numbers") end

        ---@type Vector
        local Vector = setmetatable(
            {
                Dimensions = #args,
                type = "vector",
                points = args
            }, 
            VectorProperties 
        )
        

        return Vector
    end

    --- Verifica se o valor é um Vector
    ---@param t any
    ---@return boolean isVector
    ---@return string typeName
    function Assembler.IsVector(t)
        if type(t)=="table" then
            return t.type == "vector" , "vector"
        else
            return false, type(t)
        end
    end

    
    --- Cria um vetor com todos os componentes iguais a `value`
    ---@param dimentions integer
    ---@param value number
    ---@return Vector
    function Assembler.CreateConstVector(dimentions, value)

        if not dimentions>= 1 then error("It is not possible to create a vector with a dimension smaller than 1") end

        return Assembler.transformInVector( ---@diagnostic disable-line: undefined-field
            function ()
                local v = {}
                for i=1, dimentions do
                    v[i] = value
                end
                return v
            end
        )    
    end



    --- Cria um vetor nulo de dimensão `n`
    ---@param n integer
    ---@return Vector
    function Assembler.CreateVectorZero(n)
        return Assembler.CreateConstVector(n, 0)
    end

    --- Cria um vetor com todos os componentes = 1 de dimensão `n`
    ---@param n integer
    ---@return Vector
    function Assembler.CreateVectorOne(n)
        return Assembler.CreateConstVector(n, 1)
    end

    return Assembler
end



return AssemblerCreate