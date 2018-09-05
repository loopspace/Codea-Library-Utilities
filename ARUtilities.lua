-- AR Utilities

function activate(e,b) 
    e.active = b
    if e.children then
        for k,v in ipairs(e.children) do
            activate(v,b)
        end
    end
end

local exports = {
    activate = activate
}

if cmodule then
   cmodule.export(exports)
else
   for k,v in pairs(exports) do
      _G[k] = v
   end
end