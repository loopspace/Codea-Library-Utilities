-- Rounded Rectangles

--[[
This is an auxilliary function for drawing a rectangle with possibly
curved cornders.  The first four parameters specify the rectangle.
The fifth is the radius of the corner rounding.  The optional sixth is
a way for specifying which corners should be rounded by passing a
number between 0 and 15.  The first bit corresponds to the lower-left
corner and it procedes clockwise from there.
--]]

local __RRects = {}

local function RoundedRectangle(x,y,w,h,s,c,a)
    c = c or 0
    w = w or 0
    h = h or 0
    s = s or 5
    if w < 0 then
        x = x + w
        w = -w
    end
    if h < 0 then
        y = y + h
        h = -h
    end
    w = math.max(w,2*s)
    h = math.max(h,2*s)
    a = a or 0
    pushMatrix()
    translate(x,y)
    rotate(a)
    local label = table.concat({w,h,s,c},",")
    if __RRects[label] then
        __RRects[label]:setColors(fill())
        __RRects[label]:draw()
    else
    local rr = mesh()
    local v = {}
    local ce = vec2(w/2,h/2)
    local n = 4
    local o,dx,dy
    for j = 1,4 do
        dx = -1 + 2*(j%2)
        dy = -1 + 2*(math.floor(j/2)%2)
        o = ce + vec2(dx * (w/2 - s), dy * (h/2 - s))
        if math.floor(c/2^(j-1))%2 == 0 then
    for i = 1,n do
        table.insert(v,o)
        table.insert(v,o + vec2(dx * s * math.cos((i-1) * math.pi/(2*n)), dy * s * math.sin((i-1) * math.pi/(2*n))))
        table.insert(v,o + vec2(dx * s * math.cos(i * math.pi/(2*n)), dy * s * math.sin(i * math.pi/(2*n))))
    end
    else
        table.insert(v,o)
        table.insert(v,o + vec2(dx * s,0))
        table.insert(v,o + vec2(dx * s,dy * s))
        table.insert(v,o)
        table.insert(v,o + vec2(0,dy * s))
        table.insert(v,o + vec2(dx * s,dy * s))
    end
    end
    rr.vertices = v
    rr:addRect(ce.x,ce.y,w,h-2*s)
    rr:addRect(ce.x,ce.y + (h-s)/2,w-2*s,s)
    rr:addRect(ce.x,ce.y - (h-s)/2,w-2*s,s)
    rr:setColors(fill())
    rr:draw()
    __RRects[label] = rr
    end
    popMatrix()
end

if _M then
   cmodule.export {
      RoundedRectangle = RoundedRectangle
		  }
else
   _G["RoundedRectangle"] = RoundedRectangle
end
