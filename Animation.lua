local Animation = class()

local function step(t,a,b)
    if b <= 0 then
        if t < a then
            return 0
        else
            return 1
        end
    else
        t = (t-a)/b
        return math.max(0,math.min(t,1))
    end
end

function Animation:init()
    self.processes = {}
    self.stime = 0
end

function Animation:draw()
    if self.paused then
        return
    end
    local del,n = {},0
    for k,v in ipairs(self.processes) do
        if v.clear and k ~= 1 then
            break
        end
        if v.init then
            if type(v.init) == "function" then
                v.init(ElapsedTime - self.stime,v.data)
            end
            v.startat = ElapsedTime - self.stime
            v.init = nil
        end
        v.action(step(ElapsedTime - self.stime,v.startat,v.duration),v.data)
        if ElapsedTime - self.stime - v.startat >= v.duration then
            if v.finish then
                v.finish(ElapsedTime - self.stime,v.data)
            end
            table.insert(del,k)
            n = n + 1
        end
        if v.block then
            break
        end
    end
    for k=n,1,-1 do
        table.remove(self.processes,del[k])
    end
end

--[[
parameters:
init
action
finish
duration
block
clear
--]]

function Animation:addProcess(t)
    if type(t) == "function" then
        t = {action = t}
    end
    t.init = t.init or true
    t.action = t.action or function() end
    t.duration = t.duration or 1
    t.data = t.data or {}
    table.insert(self.processes,t)
end

function Animation:addStop()
    self:addProcess({duration = -1, clear = true})
end

function Animation:addWait(t)
    self:addProcess({duration = t, clear = true, block = true})
end

function Animation:addPause()
    self:addProcess({
        duration = 0,
        clear = true,
        action = function() self:pause() end
    })
end

function Animation:endProcesses()
    for l,u in ipairs(self.processes) do
        u.speed = true
    end
end

function Animation:skipto(n)
    n = n or #self.processes
    for k=1,n-1 do
        if self.processes[k] then
            self.processes[k].duration = 0
        end
    end
end

function Animation:pause()
    self.paused = true
    self.pausedat = ElapsedTime
end

function Animation:resume()
    self.paused = false
    self.stime = self.stime + ElapsedTime - self.pausedat
end

function Animation:toggle()
    if self.paused then
        self:resume()
    else
        self:pause()
    end
end


if cmodule then
   return Animation
else
   _G["Animation"] = Animation
end
