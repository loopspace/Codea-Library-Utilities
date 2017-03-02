-- Saving or reading a boolean value.

local Boolean = {}

function Boolean.readData(t,k,b)
    local f
    if t == "global" then
        f = readGlobalData
    elseif t == "project" then
        f = readProjectData
    else
        f = readLocalData
    end
    local bol = f(k)
    if bol then
        if bol == 0 then
            return false
        else
            return true
        end
    else
        if b then
            return true
        else
            return false
        end
    end
end

function Boolean.saveData(t,k,b)
    local f
    if t == "global" then
        f = saveGlobalData
    elseif t == "project" then
        f = saveProjectData
    else
        f = saveLocalData
    end
    if b then
        f(k,1)
    else
        f(k,0)
    end
end

if cmodule then
   return Boolean
else
   _G["Boolean"] = Boolean
end
