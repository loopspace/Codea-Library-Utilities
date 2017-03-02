local mm = 1024/197
local cm = 1024/19.7
local mt = 1024/.197
local inch = mm*25.4

local function getLength(l)
    local n = tonumber(l)
    if n then
        return n
    end
    local i,j,m,u = string.find(l,"^(%d*)(%D*)$")
    if i then
        if u == "px" or u == "pcx" then
            return m
        elseif u == "pt" then
            return m * 3.653
        elseif u == "in" then
            return m * inch
        elseif u == "cm" then
            return m * cm
        elseif u == "mm" then
            return m * mm
        elseif u == "m" then
            return m * mt
        elseif u == "em" then
            local t = fontMetrics()
            return m * t.size
        elseif u == "en" then
            local t = fontMetrics()
            return m * t.size/2
        elseif u == "ex" then
            local t = fontMetrics()
            return m * t.xHeight
        elseif u == "lh" then
            local _,h = textSize("x")
            return m * h
        else
            return nil
        end
    end
    return nil
end

local function evalLength(s)
    if type(s) == "function" then
        s = s()
    end
    s = string.gsub(s,"(%d+%a+)",
        function(n) return getLength(n) or n end)
    s = "local s = " .. s .. " return s"
    local f = loadstring(s)
    s = f()
    return s
end

if cmodule then
   cmodule.export {
      evalLength = evalLength
		  }
else
   _G["evalLength"] = evalLength
end
