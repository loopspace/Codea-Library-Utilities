-- Mesh Utilities

--[[
Utility functions for meshes.  These all add shapes to a mesh, sort of. 
The older routines modified tables for vertices and colours whereas the newer ones modified the mesh directly.  They should be standardised.
--]]

if cmodule then
    Colour = unpack(cimport "Colour")
   cimport "ColourNames"
   cimport "MathsUtilities"
end

--[[
Vertex ordering:
1 -- 2
|    |
3 -- 4
--]]

local function addQuad(t)
    local m = t.mesh
    local n = t.position or 0
    if n > m.size - 12 then
        m:resize(n + 300)
    end
    local v = t.vertices
    for k,l in ipairs({1,2,3,2,3,4}) do
        m:vertex(n+k,v[l][1])
        if v[l][2] then
            m:color(n+k,v[l][2])
        end
        if v[l][3] then
            m:texCoord(n+k,v[l][3])
        end
    end
    return n + 6
end

local function addTriangle(t)
    local m = t.mesh
    local n = t.position or 0
    if n > m.size - 12 then
        m:resize(n + 300)
    end
    local v = t.vertices
    for k,l in ipairs({1,2,3}) do
        m:vertex(n+k,v[l][1])
        m:color(n+k,v[l][2])
    end
    return n + 3
end

--[[
Adds a disc to an existing mesh.
--]]
local function addDisc(t)
    local m = t.mesh
    local n = t.position or 0
    local s = t.steps or 36
    local a = 2*math.pi/s
    local c = t.centre
    local cl = t.colour
    local mj = t.majorAxis
    local mi = t.minorAxis
    local v
    if n > m.size - 3*s then
        m:resize(n + 3*s)
    end
    for i=1,s do
        m:vertex(n+3*i-2,c)
        m:vertex(n+3*i-1,c + mj * math.sin(i*a) + mi * math.cos(i*a))
        m:vertex(n+3*i,c + mj * math.sin((i-1)*a)
                 + mi * math.cos((i-1)*a))
        m:color(n+3*i-2,cl)
        m:color(n+3*i-1,cl)
        m:color(n+3*i,cl)
    end
    return n + 3*s
end

--[[
Adds a cone to an existing mesh.
--]]
local function addCone(t)
    local m = t.mesh
    local n = t.position or 0
    local s = t.steps or 36
    local a = 2*math.pi/s
    local c = t.centre
    local ap = t.apex
    local cl = t.baseColour or t.colour
    local acl = t.apexColour or t.colour
    local mj = t.majorAxis
    local mi = t.minorAxis
    local v
    if n > m.size - 3*s then
        m:resize(n + 3*s)
    end
    for i=1,s do
        m:vertex(n+3*i-2,ap)
        m:vertex(n+3*i-1,c + mj * math.sin(i*a) + mi * math.cos(i*a))
        m:vertex(n+3*i,c + mj * math.sin((i-1)*a)
                 + mi * math.cos((i-1)*a))
        m:color(n+3*i-2,cl)
        m:color(n+3*i-1,cl)
        m:color(n+3*i,cl)
    end
    return n + 3*s
end

--[[
Adds a rounded rectangle to an existing mesh
--]]

local function addRoundedRect(t)
   local m = t.mesh
   local x = t.x
   local y = t.y
   local w = t.width or 0
   local h = t.height or 0
   local s = t.radius or 10
   local c = t.corners or 0
   local a = t.anchor
   local fc = t.colour or fill()
   if a then
      x,y = RectAnchorAt(x,y,w,h,a)
   end
   local v = {}
   local nv = 0
   local ce = vec2(x + w/2,y + h/2)
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
         nv = nv + 3*n
      else
         table.insert(v,o)
         table.insert(v,o + vec2(dx * s,0))
         table.insert(v,o + vec2(dx * s,dy * s))
         table.insert(v,o)
         table.insert(v,o + vec2(0,dy * s))
         table.insert(v,o + vec2(dx * s,dy * s))
         nv = nv + 6
      end
   end
   local nrv = m.size
   m:resize(nrv + nv)
   for k,ve in ipairs(v) do
      m:vertex(nrv + k, ve)
      m:color(nrv+k,fc)
   end
   local ri = m:addRect(ce.x,ce.y,w,h-2*s)
   m:setRectColor(ri,fc)
   ri = m:addRect(ce.x,ce.y + (h-s)/2,w-2*s,s)
   m:setRectColor(ri,fc)
   ri = m:addRect(ce.x,ce.y - (h-s)/2,w-2*s,s)
   m:setRectColor(ri,fc)
end

local function AddPlank(t)
    local w = t.width
    local h = t.height
    local d = t.depth
    local o = t.origin
    local cube = {}
    local j,k,l
    for i=0,7 do
        j = 2*(i%2)-1
        k = 2*(math.floor(i/2)%2)-1
        l = 2*(math.floor(i/4)%2)-1
        table.insert(cube, o + j*w + k*h + l* d)
    end
    return AddCube({
        vertices = t.vertices,
        colours = t.colours,
        light = t.light,
        cube = cube,
        colour = t.colour or Colour.x11.Burlywood3
    })
end

local function addPlank(t)
    local w = t.width
    local h = t.height
    local d = t.depth
    local o = t.origin
    local cube = {}
    local j,k,l
    for i=0,7 do
        j = 2*(i%2)-1
        k = 2*(math.floor(i/2)%2)-1
        l = 2*(math.floor(i/4)%2)-1
        table.insert(cube, o + j*w + k*h + l* d)
    end
    return addCube({
        mesh = t.mesh,
        position = t.position,
        light = t.light,
        cube = cube,
        colour = t.colour or Colour.x11.Burlywood3
    })
end

local function AddSlab(t)
    local sc = t.startCentre
    local sh = t.startHeight
    local sw = t.startWidth
    local ec = t.endCentre
    local eh = t.endHeight
    local ew = t.endWidth
    local cube = {}
    local j,k
    for i=0,3 do
        j = 2*(i%2)-1
        k = 2*(math.floor(i/2)%2)-1
        table.insert(cube,sc + j*sh + k*sw)
        table.insert(cube,ec + j*eh + k*ew)
    end
    return AddCube({
        vertices = t.vertices,
        colours = t.colours,
        light = t.light,
        cube = cube,
        colour = t.colour or Colour.x11.Burlywood3
    })
end

local function addSlab(t)
    local sc = t.startCentre
    local sh = t.startHeight
    local sw = t.startWidth
    local ec = t.endCentre
    local eh = t.endHeight
    local ew = t.endWidth
    local cube = {}
    local j,k
    for i=0,3 do
        j = 2*(i%2)-1
        k = 2*(math.floor(i/2)%2)-1
        table.insert(cube,sc + j*sh + k*sw)
        table.insert(cube,ec + j*eh + k*ew)
    end
    return addCube({
        mesh = t.mesh,
        position = t.position,
        light = t.light,
        cube = cube,
        colour = t.colour or Colour.x11.Burlywood3
    })
end

local function AddHalfTube(t)
    local r = t.radius
    local b = {
        {t.startCentre,t.startWidth,t.startHeight},
        {t.endCentre,t.endWidth,t.endHeight}
    }
    local vertices = t.vertices
    local colours = t.colours
    local c = t.colour or Colour.svg.DarkSlateBlue
    local l = t.light:normalize()
    local n = t.number or 36
    local step = math.pi/n
    local ang,pang,lc,ver
    for i = 1,n do
        ang = i*step
        pang = (i-1)*step
        for k,v in ipairs({
            {1,pang},
            {1,ang},
            {2,ang},
            {2,ang},
            {1,pang},
            {2,pang}
        }) do
            ver = math.cos(v[2]) * b[v[1]][2] + math.sin(v[2]) * b[v[1]][3]
            table.insert(vertices,b[v[1]][1] + ver)
            lc = l:dot(ver)
            table.insert(colours,Colour.shade(c,50 + 25*lc))
        end
    end
    return vertices, colours
end

local function addHalfTube(t)
    local m = t.mesh
    local pos = t.position
    local b = {
        {t.startCentre,t.startWidth,t.startHeight},
        {t.endCentre,t.endWidth,t.endHeight}
    }
    local vertices = t.vertices
    local colours = t.colours
    local c = t.colour or Colour.svg.DarkSlateBlue
    local l = t.light:normalize()
    local n = t.number or 36
    if pos > m.size - 6*n then
        m:resize(pos + 6*n)
    end
    local step = math.pi/n
    local ang,pang,lc,ver
    for i = 1,n do
        ang = i*step
        pang = (i-1)*step
        for k,v in ipairs({
            {1,pang},
            {1,ang},
            {2,ang},
            {2,ang},
            {1,pang},
            {2,pang}
        }) do
            ver = math.cos(v[2]) * b[v[1]][2] + math.sin(v[2]) * b[v[1]][3]
            m:vertex(pos + 6*(i-1) + k,b[v[1]][1] + ver)
            lc = l:dot(ver)
            m:color(pos + 6*(i-1) + k,Colour.shade(c,50 + 25*lc))
        end
    end
    return pos + 6*n
end

--[[
Adds a tube to various tables to be passed to a mesh.
Input: table of parameters:
        radius -- doesn't seem to be used
        vertices
        colours
        texCoords
        normals
        colour
        light
        number
        startCentre
        startWidth
        startHeight
        startTexture
        endCentre
        endWidth
        endHeight
        endTexture
Output: the tables are modified in place, but also are returned:
        vertices
        colours
        texCoords
        normals
--]]
local function AddTube(t)
    local r = t.radius
    local b = {
        {t.startCentre,t.startWidth,t.startHeight,t.startTexture},
        {t.endCentre,t.endWidth,t.endHeight,t.endTexture}
    }
    local vertices = t.vertices
    local colours = t.colours
    local texcoords = t.texCoords
    local normals = t.normals
    local c = t.colour or Colour.svg.DarkSlateBlue
    local l = t.light
    if l then
        l = l:normalize()
    end
    local n = t.number or 36
    local step = 2*math.pi/n
    local ang,pang,lc,ver
    for i = 1,n do
        ang = i*step
        pang = (i-1)*step
        for k,v in ipairs({
            {1,pang},
            {1,ang},
            {2,ang},
            {2,ang},
            {1,pang},
            {2,pang}
        }) do
            ver = math.cos(v[2]) * b[v[1]][2] + math.sin(v[2]) * b[v[1]][3]
            table.insert(vertices,b[v[1]][1] + ver)
            ver = ver:normalize()
            if l then
                lc = l:dot(ver)
                table.insert(colours,Colour.shade(c,50 + 40*lc))
            else
                table.insert(colours,c)
            end
            if texcoords then
                table.insert(texcoords,
                    vec2(b[v[1]][4],v[2]/(2*math.pi)))
            end
            if normals then
                table.insert(normals,ver)
            end
        end
    end
    return vertices, colours, texcoords, normals
end

local function addTube(t)
    local m = t.mesh
    local b = {
        {t.startCentre,t.startWidth,t.startHeight,t.startTexture},
        {t.endCentre,t.endWidth,t.endHeight,t.endTexture}
    }
    local texcoords = t.texCoords
    local normals = t.normals
    local c = t.colour or Colour.svg.DarkSlateBlue
    local l = t.light
    if l then
        l = l:normalize()
    end
    local p = t.position or 0
    local n = t.number or 36
    if p > m.size - 6*n then
        m:resize(p+6*n)
    end
    local step = 2*math.pi/n
    local ang,pang,lc,ver
    for i = 1,n do
        ang = i*step
        pang = (i-1)*step
        for k,v in ipairs({
            {1,pang},
            {1,ang},
            {2,ang},
            {2,ang},
            {1,pang},
            {2,pang}
        }) do
            ver = math.cos(v[2]) * b[v[1]][2] + math.sin(v[2]) * b[v[1]][3]
            m:vertex(p+6*(i-1)+k,b[v[1]][1] + ver)
            if l then
                lc = l:dot(ver)
                m:color(p+6*(i-1)+k,Colour.shade(c,50 + 25*lc))
            else
                m:color(p+6*(i-1)+k,c)
            end
            if texcoords then
                m:texCoord(p+6*(i-1)+k,
                    vec2(b[v[1]][4],v[2]/(2*math.pi)))
            end
            if normals then
                m:normal(p+6*(i-1)+k,
                    ver:normalize())
            end
        end
    end
    return p+6*n
end

local function AddCappedTube(t)
    local r = t.radius
    local b = {
        {t.startCentre,t.startWidth,t.startHeight,t.startTexture},
        {t.endCentre,t.endWidth,t.endHeight,t.endTexture}
    }
    local vertices = t.vertices
    local colours = t.colours
    local texcoords = t.texCoords
    local normals = t.normals
    local c = t.colour or Colour.svg.DarkSlateBlue
    local l = t.light
    if l then
        l = l:normalize()
    end
    local n = t.number or 36
    local step = 2*math.pi/n
    local ang,pang,lc,ver
    for i = 1,n do
        ang = i*step
        pang = (i-1)*step
        for k,v in ipairs({
            {1,pang},
            {1,ang},
            {2,ang},
            {2,ang},
            {1,pang},
            {2,pang},
        }) do
            ver = math.cos(v[2]) * b[v[1]][2] + math.sin(v[2]) * b[v[1]][3]
            table.insert(vertices,b[v[1]][1] + ver)
            ver = ver:normalize()
            if l then
                lc = l:dot(ver)
                table.insert(colours,Colour.shade(c,50 + 40*lc))
            else
                table.insert(colours,c)
            end
            if texcoords then
                table.insert(texcoords,
                    vec2(b[v[1]][4],v[2]/(2*math.pi)))
            end
            if normals then
                table.insert(normals,ver)
            end
        end
        for k,v in ipairs({
            {1,pang,1},
            {1,ang,1},
            {1,ang,0},
            {2,pang,1},
            {2,ang,1},
            {2,ang,0},
        }) do
            ver = v[3]*(math.cos(v[2]) * b[v[1]][2] + math.sin(v[2]) * b[v[1]][3])
            table.insert(vertices,b[v[1]][1] + ver)
            ver = (b[v[1]][1] - b[v[1]%2+1][1]):normalize()
            if l then
                lc = l:dot(ver)
                table.insert(colours,Colour.shade(c,50 + 40*lc))
            else
                table.insert(colours,c)
            end
            if texcoords then
                table.insert(texcoords,
                    vec2(b[v[1]][4],v[2]/(2*math.pi)))
            end
            if normals then
                table.insert(normals,ver)
            end
        end
    end
    return vertices, colours, texcoords, normals
end

-- cube faces are in binary order: 000, 001, 010, 011 etc
local CubeFaces = {
        {1,2,3,4},
        {5,7,6,8},
        {1,5,2,6},
        {3,4,7,8},
        {2,6,4,8},
        {1,3,5,7}
    }
local function AddCube(t)
    local cube = t.cube
    local vertices = t.vertices or {}
    local colours = t.colours or {}
    local normals = t.normals or {}
    local c = t.colour or Colour.x11.Burlywood3
    local l = t.light:normalize()
    local faces = t.faces or CubeFaces
    local lc,n
    for k,v in ipairs(faces) do
        n = (cube[v[3]] - cube[v[1]]):cross(cube[v[2]] - cube[v[1]])
        if n ~= vec3(0,0,0) then
            n = n:normalize()
            lc = n:dot(l)
        end
        for i,u in ipairs({1,2,3,2,3,4}) do
            table.insert(vertices,cube[v[u]])
            table.insert(normals,n)
            table.insert(colours,
                Colour.shade(c,75 + 25*lc)
                )
        end
    end
    return vertices,colours,normals
end

local function addCube(t)
    local m = t.mesh
    local pos = t.position or 0
    if pos > m.size - 36 then
        m:resize(pos + 300)
    end
    local cube = t.cube
    local c = t.colour or Colour.x11.Burlywood3
    local l = t.light:normalize()
    local faces = t.faces or CubeFaces
    local lc,n
    for k,v in ipairs(faces) do
        n = (cube[v[3]] - cube[v[1]]):cross(cube[v[2]] - cube[v[1]])
        if n ~= vec3(0,0,0) then
            n = n:normalize()
            lc = n:dot(l)
        end
        for i,u in ipairs({1,2,3,2,3,4}) do
            m:vertex(pos + 6*(k-1) + i,cube[v[u]])
            m:color(pos + 6*(k-1) + i,Colour.shade(c,75 + 25*lc))
            m:normal(pos + 6*(k-1) + i,n)
        end
    end
    return pos + 36
end

local function AddJewel(t)
    local o = t.origin
    local a = SO3(t.axis,vec3(0,0,1))
    local n = t.sides
    local la = t.axis:len()
    for i = 1,3 do
        a[i] = la*a[i]
    end
    local vertices = t.vertices or {}
    local colours = t.colours or {}
    local clr = t.colour or Colour.svg.IndianRed
    local l = t.light:normalize()
    local th = math.pi/n
    local cs = math.cos(th)
    local sn = math.sin(th)
    local h = (1 - cs)/(1 + cs)
    local nh = 1/(1+h)
    local nhl = 1/math.sqrt(1 + nh^2)
    local k,b,c,d,nml,cl,nv
    b = a[2]
    c = cs*a[2] + sn*a[3]
    d = -sn*a[2] + cs*a[3]
    nv = 0
    for i = 1,2*n do
        k = 2*(i%2) - 1
        for j = -1,1,2 do
            table.insert(vertices,o + j*a[1])
            table.insert(vertices,o + h*k*a[1] + b)
            table.insert(vertices,o - h*k*a[1] + c)
            nml = j*nh*a[1] + .5*(1 - j*k)*b + .5*(1 + j*k)*c
            cl = nml:dot(l)/nhl
            for m=1,3 do
                table.insert(colours,Colour.shade(clr,75 + 25*cl))
            end
            nv = nv + 3
        end
        b = c
        c = cs*c + sn*d
        d = -sn*b + cs*d
    end
    return vertices,colours,nv
end

local function addJewel(t)
    local m = t.mesh
    local pos = t.position or 0
    local o = t.origin
    local a = SO3(t.axis,vec3(0,0,1))
    local n = t.sides
    if pos > m.size - 6*n then
        m:resize(pos + 6*n)
    end
    local la = t.axis:len()
    for i = 1,3 do
        a[i] = la*a[i]
    end
    local clr = t.colour or Colour.svg.IndianRed
    local l = t.light:normalize()
    local th = math.pi/n
    local cs = math.cos(th)
    local sn = math.sin(th)
    local h = (1 - cs)/(1 + cs)
    local nh = 1/(1+h)
    local nhl = 1/math.sqrt(1 + nh^2)
    local k,b,c,d,nml,cl
    b = a[2]
    c = cs*a[2] + sn*a[3]
    d = -sn*a[2] + cs*a[3]
    for i = 1,2*n do
        k = 2*(i%2) - 1
        for j = -1,1,2 do
            m:vertex(pos + 3*(i-1) +1,o + j*a[1])
            m:vertex(pos + 3*(i-1) +2,o + h*k*a[1] + b)
            m:vertex(pos + 3*(i-1) +3,o - h*k*a[1] + c)
            nml = j*nh*a[1] + .5*(1 - j*k)*b + .5*(1 + j*k)*c
            cl = nml:dot(l)/nhl
            for r=1,3 do
                m:color(pos + 3*(i-1) + r,Colour.shade(clr,75 + 25*cl))
            end
        end
        b = c
        c = cs*c + sn*d
        d = -sn*b + cs*d
    end
    return pos + 6*n
end

local function AddStar(t)
    local o = t.origin
    local s = t.size
    local l = t.light:normalize()/(math.sqrt(3))
    local vertices = t.vertices or {}
    local colours = t.colours or {}
    local b = RandomBasisR3()
    local v,n,c
    local bb = {}
    for i=0,7 do
        bb[1] = 2*(i%2)-1
        bb[2] = 2*(math.floor(i/2)%2)-1
        bb[3] = 2*(math.floor(i/4)%2)-1
        v = bb[1]*b[1] + bb[2]*b[2] + bb[3]*b[3]
        n = math.abs(v:dot(l))
        
        c = Colour.shade(Colour.x11["LemonChiffon" .. math.random(1,4)], 70+n*30)
        for m=1,3 do
            table.insert(colours,c)
            table.insert(vertices,o+s*(v - 2*bb[m]*b[m]))
        end
    end
    return vertices,colours
end

local function addStar(t)
    local m = t.mesh
    local pos = t.position or 0
    if pos > m.size - 24 then
        m:resize(pos + 300)
    end
    local o = t.origin
    local s = t.size
    local l = t.light:normalize()/(math.sqrt(3))
    local b = RandomBasisR3()
    local v,n,c
    local col = t.colour or "LemonChiffon"
    local bb = {}
    for i=0,7 do
        bb[1] = 2*(i%2)-1
        bb[2] = 2*(math.floor(i/2)%2)-1
        bb[3] = 2*(math.floor(i/4)%2)-1
        v = bb[1]*b[1] + bb[2]*b[2] + bb[3]*b[3]
        n = math.abs(v:dot(l))
        
        c = Colour.shade(Colour.x11[col .. math.random(1,4)], 70+n*30)
        for r=1,3 do
            m:vertex(pos + 3*i + r,o+s*(v - 2*bb[r]*b[r]))
            m:color(pos + 3*i + r,c)
        end
    end
    return pos + 24
end

local function addSphere(t)
    local m = t.mesh
    local p = t.position or 0
    local o = t.origin
    local s = t.size
    local l = t.light:normalize()
    local c = t.colour or Colour.svg.DarkSlateBlue
    local n = t.number or 36
    if p > m.size - 12*n*(n-1) then
        m:resize(p+12*n*(n-1))
    end
    local step = math.pi/n
    local theta,ptheta,phi,pphi,lc,ver
    for i = 2,n-1 do
        theta = i*step
        ptheta = (i-1)*step
        for j=1,2*n do
            phi = j*step
            pphi = (j-1)*step
            for k,v in ipairs({
                {ptheta,pphi},
                {ptheta,phi},
                {theta,phi},
                {theta,phi},
                {ptheta,pphi},
                {theta,pphi}
            }) do
                ver = s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))
                m:vertex(p+12*n*(i-2) + 6*(j-1)+k,o + ver)
                if l then
                    lc = l:dot(ver)
                    m:color(p+12*n*(i-2) + 6*(j-1)+k,Colour.shade(c,50 + 25*lc))
                else
                    m:color(p+12*n*(i-2) + 6*(j-1)+k,c)
                end
                if normals then
                    m:normal(p+12*n*(i-2) + 6*(j-1)+k,
                        ver:normalize())
                end
            end
        end
    end
    for i=0,1 do
        for j=1,2*n do
            phi = j*step
            pphi = (j-1)*step
            for k,v in ipairs({
                {step,pphi},
                {step,phi},
                {0,phi}
            }) do
                ver = (-1)^i* s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))
                m:vertex(p+12*n*(n-2) + i*6*n + 3*(j-1)+k,o + ver)
                if l then
                    lc = l:dot(ver)
                    m:color(p+12*n*(n-2) + i*6*n + 3*(j-1)+k,Colour.shade(c,50 + 25*lc))
                else
                    m:color(p+12*n*(n-2) + i*6*n + 3*(j-1)+k,c)
                end
                if normals then
                    m:normal(p+12*n*(n-2) + i*6*n + 3*(j-1)+k,
                        ver:normalize())
                end
            end
        end
    end
    return p+12*n*(n-1)
end

local function AddSphere(t)
    local vertices = t.vertices
    local colours = t.colours
    local normals = t.normals
    local o = t.origin
    local s = t.size
    local l = t.light:normalize()
    local c = t.colour or Colour.svg.DarkSlateBlue
    local n = t.number or 36
    local step = math.pi/n
    local theta,ptheta,phi,pphi,lc,ver
    for i = 2,n-1 do
        theta = i*step
        ptheta = (i-1)*step
        for j=1,2*n do
            phi = j*step
            pphi = (j-1)*step
            for k,v in ipairs({
                {ptheta,pphi},
                {ptheta,phi},
                {theta,phi},
                {theta,phi},
                {ptheta,pphi},
                {theta,pphi}
            }) do
                ver = s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))
                table.insert(vertices,o + ver)
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver:normalize())
                end
            end
        end
    end
    for i=0,1 do
        for j=1,2*n do
            phi = j*step
            pphi = (j-1)*step
            for k,v in ipairs({
                {step,pphi},
                {step,phi},
                {0,phi}
            }) do
                ver = (-1)^i* s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))
                table.insert(vertices,o + ver)
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 25*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver:normalize())
                end
            end
        end
    end
    return vertices,colours,normals
end

local function AddSemiSphere(t)
    local vertices = t.vertices
    local colours = t.colours
    local normals = t.normals
    local o = t.origin
    local q = vec3(0,0,1):rotateTo(t.direction)
    local s = t.size
    local l
    if t.light then
        l = t.light:normalize()
    end
    local c = t.colour or Colour.svg.DarkSlateBlue
    local n = t.number or 36
    n = n + n%4
    local step = 2*math.pi/n
    local theta,ptheta,phi,pphi,lc,ver
    for i = 2,n/4 do
        theta = i*step
        ptheta = (i-1)*step
        for j=1,n do
            phi = j*step
            pphi = (j-1)*step
            for k,v in ipairs({
                {ptheta,pphi},
                {ptheta,phi},
                {theta,phi},
                {theta,phi},
                {ptheta,pphi},
                {theta,pphi}
            }) do
                ver = s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    end
    for j=1,n do
        phi = j*step
        pphi = (j-1)*step
        for k,v in ipairs({
            {step,pphi},
            {step,phi},
            {0,phi}
            }) do
                ver =  s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    return vertices,colours,normals
end

local function AddCappedSemiSphere(t)
    local vertices = t.vertices
    local colours = t.colours
    local normals = t.normals
    local o = t.origin
    local q = vec3(0,0,1):rotateTo(t.direction)
    local s = t.size
    local l
    if t.light then
        l = t.light:normalize()
    end
    local c = t.colour or Colour.svg.DarkSlateBlue
    local n = t.number or 36
    n = n + n%4
    local step = 2*math.pi/n
    local theta,ptheta,phi,pphi,lc,ver
    for i = 2,n/4 do
        theta = i*step
        ptheta = (i-1)*step
        for j=1,n do
            phi = j*step
            pphi = (j-1)*step
            for k,v in ipairs({
                {ptheta,pphi},
                {ptheta,phi},
                {theta,phi},
                {theta,phi},
                {ptheta,pphi},
                {theta,pphi}
            }) do
                ver = s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    end
    for j=1,n do
        phi = j*step
        pphi = (j-1)*step
        for k,v in ipairs({
            {step,pphi},
            {step,phi},
            {0,phi}
            }) do
                ver =  s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    for j=1,n do
        phi = j*step
        pphi = (j-1)*step
        for k,v in ipairs({
            {math.pi/2,pphi,1},
            {math.pi/2,phi,1},
            {0,phi,0}
            }) do
                ver =  v[3]*s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = vec3(0,-1,0)^q
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
        end
    end
    return vertices,colours,normals
end

local function AddCappedSphereJoint(t)
    local vertices = t.vertices
    local colours = t.colours
    local normals = t.normals
    local up = t.incoming:cross(t.outgoing):normalize()
    local q = vec3(0,0,1):rotateTo(up)
    local inc = up:cross(t.incoming):normalize()
    if inc:dot(t.outgoing) > 0 then
        inc = - inc
    end
    local out = up:cross(t.outgoing):normalize()
    if out:dot(t.incoming) > 0 then
        out = - out
    end
    q = (vec3(1,0,0)^q):rotateTo(inc)*q
    local ang = math.atan2(up:cross(inc):dot(out),inc:dot(out))
    local o = t.origin
    local s = t.size
    local l
    if t.light then
        l = t.light:normalize()
    end
    local c = t.colour or Colour.svg.DarkSlateBlue
    local n = t.number or 36
    local step = math.pi/n
    local nh = math.ceil(math.abs(ang/step))
    local hstep = ang/nh
    local theta,ptheta,phi,pphi,lc,ver
    for i = 2,n-1 do
        theta = i*step
        ptheta = (i-1)*step
        for j=1,nh do
            phi = j*hstep
            pphi = (j-1)*hstep
            for k,v in ipairs({
                {ptheta,pphi},
                {ptheta,phi},
                {theta,phi},
                {theta,phi},
                {ptheta,pphi},
                {theta,pphi}
            }) do
                ver = s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    end
    for i=-1,1,2 do
        for j=1,nh do
            phi = j*hstep
            pphi = (j-1)*hstep
            for k,v in ipairs({
                {step,pphi},
                {step,phi},
                {0,phi}
                }) do
                ver =  s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),i*math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    end
    inc,out = t.incoming:normalize(),t.outgoing:normalize()
    for i = 1,n do
        theta = i*step
        ptheta = (i-1)*step
        for k,v in ipairs({
            {theta,0,1},
            {ptheta,0,1},
            {0,0,0},
            {theta,ang,1},
            {ptheta,ang,1},
            {0,0,0},
            }) do
                ver =  v[3]*s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                if k <= 3 then
                    ver = inc
                else
                    ver = out
                end
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
        end
    end
    return vertices,colours,normals
end

local function AddSphereJoint(t)
    local vertices = t.vertices
    local colours = t.colours
    local normals = t.normals
    local up = t.incoming:cross(t.outgoing):normalize()
    local q = vec3(0,0,1):rotateTo(up)
    local inc = up:cross(t.incoming):normalize()
    if inc:dot(t.outgoing) > 0 then
        inc = - inc
    end
    local out = up:cross(t.outgoing):normalize()
    if out:dot(t.incoming) > 0 then
        out = - out
    end
    q = (vec3(1,0,0)^q):rotateTo(inc)*q
    local ang = math.atan2(up:cross(inc):dot(out),inc:dot(out))
    local o = t.origin
    local s = t.size
    local l
    if t.light then
        l = t.light:normalize()
    end
    local c = t.colour or Colour.svg.DarkSlateBlue
    local n = t.number or 36
    local step = math.pi/n
    local nh = math.ceil(math.abs(ang/step))
    local hstep = ang/nh
    local theta,ptheta,phi,pphi,lc,ver
    for i = 2,n-1 do
        theta = i*step
        ptheta = (i-1)*step
        for j=1,nh do
            phi = j*hstep
            pphi = (j-1)*hstep
            for k,v in ipairs({
                {ptheta,pphi},
                {ptheta,phi},
                {theta,phi},
                {theta,phi},
                {ptheta,pphi},
                {theta,pphi}
            }) do
                ver = s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    end
    for i=-1,1,2 do
        for j=1,nh do
            phi = j*hstep
            pphi = (j-1)*hstep
            for k,v in ipairs({
                {step,pphi},
                {step,phi},
                {0,phi}
                }) do
                ver =  s*vec3(math.sin(v[1])*math.cos(v[2]),math.sin(v[1])*math.sin(v[2]),i*math.cos(v[1]))^q
                table.insert(vertices,o + ver)
                ver = ver:normalize()
                if l then
                    lc = l:dot(ver)
                    table.insert(colours,Colour.shade(c,50 + 40*lc))
                else
                    table.insert(colours,c)
                end
                if normals then
                    table.insert(normals,ver)
                end
            end
        end
    end

    return vertices,colours,normals
end

local exports = {
    addQuad = addQuad,
    addTriangle = addTriangle,
    addRoundedRect = addRoundedRect,
    AddPlank = AddPlank,
    AddSlab = AddSlab,
    AddTube = AddTube,
    AddHalfTube = AddHalfTube,
    AddCube = AddCube,
    AddJewel = AddJewel,
    AddStar = AddStar,
    addDisc = addDisc,
    addTube = addTube,
    addCone = addCone,
    addCube = addCube,
    addJewel = addJewel,
    addStar = addStar,
    addPlank = addPlank,
    addSlab = addSlab,
    addHalfTube = addHalfTube,
    addSphere = addSphere,
    AddSphere = AddSphere,
    AddSemiSphere = AddSemiSphere,
    AddCappedTube = AddCappedTube,
    AddCappedSemiSphere = AddCappedSemiSphere,
    AddCappedSphereJoint = AddCappedSphereJoint,
    AddSphereJoint = AddSphereJoint
}

if cmodule then
   cmodule.export(exports)
else
   for k,v in pairs(exports) do
      _G[k] = v
   end
end
