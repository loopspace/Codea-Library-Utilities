--[[
Some mathematical utilities.
--]]

local Matrix = Matrix

local function Ordinal(n)
    local k = n%10
    local th = "th"
    if k == 1 then
        th = "st"
    elseif k == 2 then
        th = "nd"
    elseif k == 3 then
        th = "rd"
    end
    return n .. th
end
        
local function Regression(t)
    local Matrix
    if _M then
        if cmodule.loaded "Matrix" then
            Matrix = cimport "Matrix"
        end
    else
        Matrix = function(t) return t end
    end
    local n, xy, x, y, xx, yy = 0,0,0,0,0,0
    for k,v in ipairs(t) do
        n = n + 1
        xy = xy + v.x*v.y
        x = x + v.x
        y = y + v.y
        xx = xx + v.x*v.x
        yy = yy + v.y*v.y
    end
    local d = n*xx - x*x
    local matrix
    if Matrix then
        matrix = Matrix({{0,0},{0,0}})
    else
        matrix = {{0,0},{0,0}}
    end
    if d == 0 then
        return false,false,matrix
    end
    return (n*xy - x*y)/d,
            (-x*xy + xx*y)/d,
            Matrix({{xx,x},{x,n}}),
            (n*xy -x*y)^2/((n*xx-x*x)*(n*yy-y*y))
end

local function ApplyAffine(m,v)
    if v then
        return v.x*m[1] + v.y*m[2] + m[3]
    else
        applyMatrix(matrix(
            m[1].x, m[1].y, 0, 0,
            m[2].x, m[2].y, 0, 0,
            0,0,1,0,
            m[3].x, m[3].y, 0, 1
        ))
    end
end

local function USRotateCW(v)
    return ApplyAffine({vec2(0,-1),vec2(1,0),vec2(0,1)},v)
end

local function USRotateCCW(v)
    return ApplyAffine({vec2(0,1),vec2(-1,0),vec2(1,0)},v)
end

local function USReflectV(v)
    return ApplyAffine({vec2(-1,0),vec2(0,1),vec2(1,0)},v)
end

local function USReflectH(v)
    return ApplyAffine({vec2(1,0),vec2(0,-1),vec2(0,1)},v)
end

local USCoordinates = {}
USCoordinates[PORTRAIT] = {vec2(1,0),vec2(0,1),vec2(0,0)}
USCoordinates[PORTRAIT_UPSIDE_DOWN] = {vec2(-1,0),vec2(0,-1),vec2(1,1)}
USCoordinates[LANDSCAPE_LEFT] = {vec2(0,-1),vec2(1,0),vec2(0,1)}
USCoordinates[LANDSCAPE_RIGHT] = {vec2(0,1),vec2(-1,0),vec2(1,0)}

local function USOrientation(o,v)
    return ApplyAffine(USCoordinates[o],v)
end

local InvUSCoordinates = {}
InvUSCoordinates[PORTRAIT] = {vec2(1,0),vec2(0,1),vec2(0,0)}
InvUSCoordinates[PORTRAIT_UPSIDE_DOWN] = {vec2(-1,0),vec2(0,-1),vec2(1,1)}
InvUSCoordinates[LANDSCAPE_LEFT] = {vec2(0,1),vec2(-1,0),vec2(1,0)}
InvUSCoordinates[LANDSCAPE_RIGHT] = {vec2(0,-1),vec2(1,0),vec2(0,1)}

local function InvUSOrientation(o,v)
    return ApplyAffine(InvUSCoordinates[o],v)
end

local function TriangleArea(a,b,c)
    return math.abs(
        a:dot(b:rotate90())
        + b:dot(c:rotate90())
        + c:dot(a:rotate90())
    )/2
end

local function Shoelace(p)
    local n = #p
    local a = 0
    for k=1,n do
        a = a + p[k].x * (p[k%n+1].y - p[(k-2)%n+1].y) 
    end
    return math.abs(a)/2
end

local function applymatrix4(v,m)
    local u = {}
    u[1] = m[1]*v[1] + m[5]*v[2] + m[09]*v[3] + m[13]*v[4]
    u[2] = m[2]*v[1] + m[6]*v[2] + m[10]*v[3] + m[14]*v[4]
    u[3] = m[3]*v[1] + m[7]*v[2] + m[11]*v[3] + m[15]*v[4]
    u[4] = m[4]*v[1] + m[8]*v[2] + m[12]*v[3] + m[16]*v[4]
    return u
end

local function cofactor4(m)
    local rm = matrix()
    local sgn,l
    local fm = {}
    for k=1,16 do
        fm = {}
        l = math.floor((k-1)/4) + 1 + 4*((k-1)%4)
        sgn = (-1)^(math.floor((k-1)/4))*(-1)^((k-1)%4)
        for j=1,16 do
            if j%4 ~= k%4 
                and math.floor((j-1)/4) ~= math.floor((k-1)/4)
                then
                    table.insert(fm,m[j])
            end
        end
        rm[l] = sgn*Det3(fm)
    end
    return rm
end
                
local function Det3(t)
    return t[1]*t[5]*t[9]
         + t[2]*t[6]*t[7]
         + t[3]*t[4]*t[8]
         - t[3]*t[5]*t[7]
         - t[2]*t[4]*t[9]
         - t[1]*t[6]*t[8]
end

local function applymatrix3(v,m)
    local u = {}
    u[1] = m[1]*v[1] + m[4]*v[2] + m[7]*v[3]
    u[2] = m[2]*v[1] + m[5]*v[2] + m[8]*v[3]
    u[3] = m[3]*v[1] + m[6]*v[2] + m[9]*v[3]
    return u
end

local function Det2(t)
    return t[1]*t[4] - t[2]*t[3]
end

local function cofactor3(m)
    local rm = {}
    local sgn,l
    local fm = {}
    for k=1,9 do
        fm = {}
        l = math.floor((k-1)/3) + 1 + 3*((k-1)%3)
        sgn = (-1)^(math.floor((k-1)/3))*(-1)^((k-1)%3)
        for j=1,9 do
            if j%3 ~= k%3 
                and math.floor((j-1)/3) ~= math.floor((k-1)/3)
                then
                    table.insert(fm,m[j])
            end
        end
        rm[l] = sgn*Det2(fm)
    end
    return rm
end

local function RandomVec3()
    local th = 2*math.pi*math.random()
    local z = 2*math.random() - 1
    local r = math.sqrt(1 - z*z)
    return vec3(r*math.cos(th),r*math.sin(th),z)
end

local function RandomBasisR3()
    local th = 2*math.pi*math.random()
    local cth = math.cos(th)
    local sth = math.sin(th)
    local a = vec3(cth,sth,0)
    local b = vec3(-sth,cth,0)
    local c = vec3(0,0,1)
    local v = RandomVec3()
    a = a - 2*v:dot(a)*v
    b = b - 2*v:dot(b)*v
    c = c - 2*v:dot(c)*v
    return {a,b,c}
end

local function GramSchmidt(t)
    local o = {}
    local w
    for k,v in ipairs(t) do
        w = v
        for l,u in ipairs(o) do
            w = w - w:dot(u)*u
        end
        if w ~= vec3(0,0,0) then
            w = w:normalize()
            table.insert(o,w)
        end
    end
    return o
end

local function SO3(u,v)
    u = u or vec3(0,0,0)
    v = v or vec3(0,0,0)
    if u == vec3(0,0,0) then
        if v == vec3(0,0,0) then
            return {vec3(1,0,0),vec3(0,1,0),vec3(0,0,1)}
        end
        u,v = v,u
    end
    if u:cross(v) == vec3(0,0,0) then
        if u.x == 0 and u.y == 0 then
            v = vec3(1,0,0)
        else
            v = vec3(u.y,-u.x,0)
        end
    end
    local t = GramSchmidt({u,v})
    t[3] = t[1]:cross(t[2])
    return t
end

local function TriangleIntersect(a,b,c,d,e,f,ep)
    if type(a) ~= "table" then
        a,b,c,d,e = {a,b,c},d,e,f,ep
    end
    if type(b) ~= "table" then
        b,c = {b,c,d},e
    end
    c = c or 0
    local n,rt
    for k=1,2 do
        for i=1,3 do
            n = (a[i%3+1]-a[i]):rotate90()
            n = n * n:dot(a[(i+1)%3+1] - a[i])
            rt = true
            for j=1,3 do
                if n:dot(b[j] - a[i]) > c then
                    rt = false
                end
            end
            if rt then
                return false
            end
        end
        a,b = b,a
    end
    return true
end

local function KnuthShuffle(n,odd)
    local l
    local o = 0
    local p = {}
    for k = 1,n do
        p[k] = k
    end
    for k = 1,n-1 do
        l = math.random(k,n)
        if l ~= k then
            p[k],p[l] = p[l],p[k]
            o = 1 - o
        end
    end
    if not odd and o == 1 then
        p[1],p[2] = p[2],p[1]
    end
    return p
end

local function SattoloShuffle(n)
    local l
    local p = {}
    for k = 1,n do
        p[k] = k
    end
    for k = 1,n-2 do
        l = math.random(k+1,n)
        p[k],p[l] = p[l],p[k]
    end
    p[n-1],p[n] = p[n],p[n-1]
    return p
end

local __subfactorials = {1,0}
local function subfactorial(n)
    if __subfactorials[n+1] then
        return __subfactorials[n+1]
    end
    if __subfactorials[n] then
        __subfactorials[n+1] = (n-1)*(__subfactorials[n] +     __subfactorials[n-1])
        return __subfactorials[n+1]
    end
    for k=2,n do
        subfactorial(k)
    end
    return __subfactorials[n+1]
end

local function Derangement(n)
    local j,l
    local p = {}
    local m = {}
    local i,u = n,n
    for k = 1,n do
        p[k] = k
        m[k] = false
    end
    while u >= 2 do
        if not m[i] then
            j = math.random(1,u-1)
            k = 1
            while k <= j do
                if m[k] then
                    j = j + 1
                end
                k = k + 1
            end
            p[i],p[j] = p[j],p[i]
            l = math.random()
            if l < (u-1) * subfactorial(u-2)/subfactorial(u) then
                m[j] = true
                u = u - 1
            end
            u = u - 1
        end
        i = i - 1
    end
    return p
end

local exports = {
    Ordinal = Ordinal,
    Regression = Regression,
    ApplyAffine = ApplyAffine,
    USRotateCW = USRotateCW,
    USRotateCCW = USRotateCCW,
    USReflectV = USReflectV,
    USReflectH = USReflectH,
    USOrientation = USOrientation,
    InvUSOrientation = InvUSOrientation,
    TriangleArea = TriangleArea,
    applymatrix4 = applymatrix4,
    cofactor4 = cofactor4,
    Det3 = Det3,
    applymatrix3 = applymatrix3,
    cofactor3 = cofactor3,
    Det2 = Det2,
    RandomVec3 = RandomVec3,
    RandomBasisR3 = RandomBasisR3,
    SO3 = SO3,
    GramSchmidt = GramSchmidt,
    TriangleIntersect = TriangleIntersect,
    KnuthShuffle = KnuthShuffle,
    Permutation = KnuthShuffle,
    CyclicPermutation = SattoloShuffle,
    Derangement = Derangement,
    Shoelace = Shoelace
}

if cmodule then
   cmodule.export(exports)
else
   for k,v in pairs(exports) do
      _G[k] = v
   end
end