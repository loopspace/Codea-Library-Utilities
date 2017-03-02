-- Playlist

local Playlist = class()

function Playlist:init(t)
    t = t or {}
    self.startat = t.startTime or 0
    if t.skipTo then
        self.skip = t.skipTo
        self.startat = self.startat - t.skipTo
    end
    self.current = t.startTime or 0
    self.lastaction = t.lastAction
    self.pauseaction = t.pauseAction
    self.resumeaction = t.resumeAction
    self.events = {}
    if t.ui and cmodule and cmodule.loaded "Menu" then
    local attach = true
    if t.standalone then
        attach = false
    end
    local mopts = t.menuOpts or {}
    local title = t.title or "Playlist"
    local m = t.ui:addMenu({title = title, attach = attach, menuOpts = mopts})
    m:addItem({title = "Start",
        action = function()
            self:start()
            return true
        end,
        highlight = function()
            return self.running
        end
        })
    m:addItem({title = "Stop",
        action = function()
            self:stop()
            return true
        end
        })
    m:addItem({title = "Pause",
        action = function()
            self:pause()
            return true
        end,
        highlight = function()
            return self.paused
        end
        })
    m:addItem({title = "Resume",
        action = function()
            self:resume()
            return true
        end
        })
    end
end

function Playlist:addEvent(t)
    t = t or {}
    local ti = t.time or 0
    if t.relative then
        ti = ti + self.current
    end
    if t.duration then
        self.current = ti + t.duration
        table.insert(self.events,{ti,t.event})
    elseif t.step and t.number then
        for k = 1,t.number do
            table.insert(self.events,{ti,t.event})
            ti = ti + t.step
        end
        self.current = ti
    end
    
end

function Playlist:wait(t)
    if t then
        self.current = self.current + t
    end
end

function Playlist:draw()
    if self.active then
        local dels = {}
        for k,e in ipairs(self.events) do
            if self.skip and e[1] < self.skip then
                table.insert(dels,1,k)
            else
                if ElapsedTime - self.startat > e[1] and e[2]() then
                    table.insert(dels,1,k)
                end
            end
        end
        for k,v in ipairs(dels) do
            table.remove(self.events,v)
        end
    end
end

function Playlist:start()
    self.active = true
    self.running = true
    self.startat = ElapsedTime
    if self.skip then
        self.startat = self.startat - self.skip
    end
end

function Playlist:pause()
    self.active = false
    self.paused = true
    self.pausedat = ElapsedTime
    if self.pauseaction then
        self.pauseaction()
    end
end

function Playlist:resume()
    self.active = true
    self.paused = false
    if self.pausedat then
        self.startat = self.startat + ElapsedTime - self.pausedat
    end
    if self.resumeaction then
        self.resumeaction()
    end
end

function Playlist:stop()
    self.active = false
    self.running = false
    if self.lastaction then
        self.lastaction()
    end
end

if cmodule then
   return Playlist
else
   _G["Playlist"] = Playlist
end
