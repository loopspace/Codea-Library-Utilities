--[[
Functions for converting a touch to and from the screen.
--]]

if cmodule then
   cimport "MathsUtilities"
end
    
local function converttouch(z,t,A)
    A = A or modelMatrix() * viewMatrix() * projectionMatrix()
    t = t or CurrentTouch or vec2(0,0)
    z = z or 0
    local m = cofactor4(A)
    local ndc = {}
    local a
    ndc[1] = (t.x/WIDTH - .5)*2
    ndc[2] = (t.y/HEIGHT - .5)*2
    ndc[3] = z
    ndc[4] = 1
    a = applymatrix4(ndc,m)
    if (a[4] == 0) then return end
    a = vec3(a[1], a[2], a[3])/a[4]
    return a
end

local function getzlevel(v,A)
    A = A or modelMatrix() * viewMatrix() * projectionMatrix()
    v = v or vec3(0,0,0)
    local u = applymatrix4(vec4(v.x,v.y,v.z,1),A)
    if u[4] == 0 then return end
    return u[3]/u[4]
end


local function __planetoscreen(o,u,v,A)
    A = A or modelMatrix() * viewMatrix() * projectionMatrix()
    o = o or vec3(0,0,0)
    u = u or vec3(1,0,0)
    v = v or vec3(0,1,0)
    -- promote to 4-vectors
    o = vec4(o.x,o.y,o.z,1)
    u = vec4(u.x,u.y,u.z,0)
    v = vec4(v.x,v.y,v.z,0)
    local oA, uA, vA
    oA = applymatrix4(o,A)
    uA = applymatrix4(u,A)
    vA = applymatrix4(v,A)
    return { uA[1], uA[2], uA[4],
             vA[1], vA[2], vA[4],
             oA[1], oA[2], oA[4]}
end

local function screentoplane(t,o,u,v,A)
    A = A or modelMatrix() * viewMatrix() * projectionMatrix()
    o = o or vec3(0,0,0)
    u = u or vec3(1,0,0)
    v = v or vec3(0,1,0)
    t = t or CurrentTouch
    local m = __planetoscreen(o,u,v,A)
    m = cofactor3(m)
    local ndc = {}
    local a
    ndc[1] = (t.x/WIDTH - .5)*2
    ndc[2] = (t.y/HEIGHT - .5)*2
    ndc[3] = 1
    a = applymatrix3(ndc,m)
    if (a[3] == 0) then return end
    a = vec2(a[1], a[2])/a[3]
    return o + a.x*u + a.y*v
end

local function screenframe(t,A)
    A = A or modelMatrix() * viewMatrix() * projectionMatrix()
    t = t or CurrentTouch
    local u,v,w,x,y
    u = vec3(A[1],A[5],A[9])
    v = vec3(A[2],A[6],A[10])
    w = vec3(A[4],A[8],A[12])
    x = (t.x/WIDTH - .5)*2
    y = (t.y/HEIGHT - .5)*2
    u = u - x*w
    v = v - y*w
    return u:cross(v),u,v
end

local function screennormal(t,A)
    local u,v,w = screenframe(t,A)
    return u
end

local exports = {
    screennormal = screennormal,
    screenframe = screenframe,
    screentoplane = screentoplane,
    converttouch = converttouch,
    getzlevel = getzlevel
}

if cmodule then
   cmodule.export(exports)
else
   for k,v in pairs(exports) do
      _G[k] = v
   end
end