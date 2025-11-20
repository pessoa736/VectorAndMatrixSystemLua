local initTime = 0
local finalTime = 0
local dt = 0
local clock = os.clock


local function Metric(shortName, currentTime, interval, isRaw)
    return not isRaw and ((currentTime*interval)//0.01)*0.01 .. shortName or {
        dt = currentTime,
        int = interval, 
        unit=shortName
    }
end

return {
    setStart = function ()
        initTime = os.clock()
        return initTime
    end,
    setFinal = function ()
        finalTime = os.clock()
        return finalTime
    end,
    showtime = function(isRaw, time)
        dt = time or finalTime - initTime; 
        
        if dt <1e-6 then 
            return Metric("ns", dt, 1e9, isRaw) 
        elseif dt < 1e-3 then 
            return  Metric("μs", dt, 1e6, isRaw) 
        elseif dt<1 then 
            return Metric("ms", dt, 1e3, isRaw) 
        elseif dt<60 then 
            return Metric("s", dt, 1, isRaw)
        elseif dt<60*60 then 
            return Metric("min", dt, 1/60, isRaw)
        else
            return Metric("min", dt, 1/3600, isRaw)
        end
    end,
    reapeatTest = function(s, rep, funct)
        local sum = 0
        local min, max = 0, 0
        for i=1, rep do
            local t = clock()
            funct()
            local dt = clock() - t
            sum=sum+dt
            if i==1 then
                min = dt
                max = dt
            end
            if dt>max then max = dt end
            if dt<min then min = dt end
        end

        return {
                max = s.showtime(false, max),
                min = s.showtime(false, min),
                med = s.showtime(false, sum/rep)
            }
    end
}