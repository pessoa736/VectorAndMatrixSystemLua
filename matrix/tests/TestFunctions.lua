local initTime = 0
local finalTime = 0
local dt = 0

return {
    setStart = function ()
        initTime = os.clock()
    end,
    setFinal = function ()
        finalTime = os.clock()
    end,
    showtime = function()
        dt = finalTime - initTime; 

        if dt/60 >= 1 and dt/60<60 then
            return dt .. "min"
        end
        

        if dt >= 0.1 and dt<60 then
            return dt .. "s"
        end
        
        if dt >= 0.0001 and dt<0.1 then
            return (dt*1000) .. "ms"
        end

        if dt >= 0.0000001 and dt<0.0001 then
            return (dt*1000000) .. "μs"
        end

        return dt
    end
}