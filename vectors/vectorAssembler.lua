

function AssemblerCreate(VectorProperties)
    local Assembler = {}

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

    function Assembler.IsVector(t)
        if type(t)=="table" then
            return t.type == "vector" , "vector";
        else
            return false, type(t);
        end
    end

    
    function Assembler.CreateConstVector(dimentions, value)

        if not dimentions>= 1 then error("It is not possible to create a vector with a dimension smaller than 1") end

        return Assembler.transformInVector(
            function ()
                local v = table.create(dimentions)
                for i=1, dimentions do
                    v[i] = value
                end
                return v
            end
        )    
    end



    function Assembler.CreateVectorZero(n)
        return Assembler.CreateConstVector(n, 0)
    end

    function Assembler.CreateVectorOne(n)
        return Assembler.CreateConstVector(n, 1)
    end

    return Assembler
end



return AssemblerCreate