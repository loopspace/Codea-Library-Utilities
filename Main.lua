--The name of the project must match your Codea project name if dependencies are used. 
--Project: Library Utilities
--Version: 2.0
--Dependencies:
--Comments:

VERSION = 2.0
clearProjectData()
-- DEBUG = true
-- Use this function to perform your initial setup
function setup()
    if AutoGist then
    autogist = AutoGist("Library Utilities","A library of utility classes and functions.",VERSION)
    autogist:backup(true)
    end
    if not cmodule then
        openURL("http://loopspace.mathforge.org/discussion/36/my-codea-libraries")
        print("You need to enable the module loading mechanism.")
        print("See http://loopspace.mathforge.org/discussion/36/my-codea-libraries")
        print("Touch the screen to exit the program.")
        draw = function()
        end
        touched = function()
            close()
        end
        return
    end
    --displayMode(FULLSCREEN_NO_BUTTONS)
    cmodule "Library Utilities"
    cmodule.path("Library Base", "Library Maths", "Library Graphics")
    cimport "Lengths"
    cimport "RoundedRectangle"
    Colour = unpack(cimport "Colour")
    cimport "ColourNames"
    cimport "VecExt"
    cimport "MeshUtilities"
    cimport "MathsUtilities"
    
    print(TriangleIntersect(vec2(0,0),vec2(1,0),vec2(0,1),vec2(2,2),vec2(3,2),vec2(2,3)))
    print(TriangleIntersect(vec2(0,0),vec2(1,0),vec2(0,1),vec2(0,0),vec2(3,2),vec2(2,3)))
    print(TriangleIntersect(vec2(0,0),vec2(1.000001,0),vec2(0,1),vec2(1,0),vec2(0,1),vec2(1,1),0.001))
    
    touches = cimport "Touch"()
    view = cimport "View"(nil,touches)
    print(evalLength("1cm+2ex*3 + 8pt"))
    print(1024/197)
    local ver,col = {},{}
    local inc,out = vec3(-1,0,0),vec3(0,1,0)
    ver,col = AddSphereJoint({
        vertices = ver,
        colours = col,
        light = vec3(1,0,0),
        origin = vec3(0,0,0),
        incoming = inc,
        outgoing = out,
        size = 1,
        number = 6
    })
    inc,out = vec3(-1.4,0,0)^vec4(-1,0,0,0),vec3(0,1,0)
    ver,col = AddCappedSphereJoint({
        vertices = ver,
        colours = col,
        light = vec3(1,0,0),
        origin = vec3(0,0,0),
        incoming = inc,
        outgoing = out,
        size = 1,
        number = 6
    })
    m = mesh()
    m.vertices = ver
    m.colors = col
    axes = mesh()
    local position = 0
    local radius = .03
    local xmin,ymin,zmin = -2,-1.5,-1
    local xmax,ymax,zmax = 2,1.5,1
    local d = {vec3(1,0,0),vec3(0,1,0),vec3(0,0,1)}
    for k,v in ipairs({
        {xmin-1,xmax+1},
        {ymin-1,ymax+1},
        {zmin-1,zmax+1},
    }) do
    position = addTube({
        mesh = axes,
        position = position,
        startCentre = v[1]*d[k],
        startWidth = radius*d[k%3+1],
        startHeight = radius*d[(k+1)%3+1],
        endCentre = v[2]*d[k],
        endWidth = radius*d[k%3+1],
        endHeight = radius*d[(k+1)%3+1],
        colour = Colour.svg.Black
    })
    position = addDisc({
        mesh = axes,
        centre = v[1]*d[k],
        majorAxis = radius*d[k%3+1],
        minorAxis = radius*d[(k+1)%3+1],
        position = position,
        colour = Colour.svg.Black
    })
    position = addDisc({
        mesh = axes,
        centre = v[2]*d[k],
        majorAxis = 2*radius*d[k%3+1],
        minorAxis = 2*radius*d[(k+1)%3+1],
        position = position,
        colour = Colour.svg.Black
    })
    position = addCone({
        mesh = axes,
        centre = v[2]*d[k],
        majorAxis = 2*radius*d[k%3+1],
        minorAxis = 2*radius*d[(k+1)%3+1],
        apex = (v[2]+.3)*d[k],
        position = position,
        colour = Colour.svg.Black
    })
    end
    local q
    for k,v in ipairs({inc,out}) do
        q = vec3(1,0,0):rotateTo(v)
    position = addTube({
        mesh = axes,
        position = position,
        startCentre = vec3(0,0,0),
        startWidth = radius*vec3(0,1,0)^q,
        startHeight = radius*vec3(0,0,1)^q,
        endCentre = v,
        endWidth = radius*vec3(0,1,0)^q,
        endHeight = radius*vec3(0,0,1)^q,
        colour = Colour.svg.HotPink
    })
    position = addDisc({
        mesh = axes,
        centre = vec3(0,0,0),
        majorAxis = radius*vec3(0,1,0)^q,
        minorAxis = radius*vec3(0,0,1)^q,
        position = position,
        colour = Colour.svg.HotPink
    })
    position = addDisc({
        mesh = axes,
        centre = v,
        majorAxis = 2*radius*vec3(0,1,0)^q,
        minorAxis = 2*radius*vec3(0,0,1)^q,
        position = position,
        colour = Colour.svg.HotPink
    })
    position = addCone({
        mesh = axes,
        centre = v,
        majorAxis = 2*radius*vec3(0,1,0)^q,
        minorAxis = 2*radius*vec3(0,0,1)^q,
        apex = 1.3*v,
        position = position,
        colour = Colour.svg.HotPink
    })
    end
end

-- This function gets called once every frame
function draw()
    -- process touches and taps
    touches:draw()
    background(34, 47, 53, 255)
    stroke(Colour.svg.Aquamarine)
    strokeWidth(5)
    line(100,100,evalLength("10ex+100"),100)
    line(100,110,evalLength("1cm+100"),110)
    line(100,120,evalLength("10mm+100"),120)
    line(100,130,evalLength("1in+100"),130)
    RoundedRectangle(100,200,300,100,5)
    view:draw()
    axes:draw()
    m:draw()
end

function touched(touch)
    touches:addTouch(touch)
end

function orientationChanged(o)
end

function fullscreen()
end

function reset()
end
