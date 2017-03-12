local vector = require("vector")
local M = {}

local function addLine(lines, a, b)
   table.insert(lines, {a, b})
end

local function addFace(faces, ...)
   table.insert(faces, {...})
end

local function draw(self, canvas3d)
   for _, points in ipairs(self.lines) do
      canvas3d:line(points[1], points[2])
   end
end

local function drawj(self, canvas3d)
   for _, points in ipairs(self.faces) do
      canvas3d:polygon("fill", points)
   end
end

local function new(p1, p2)
   local c = {}
   c.draw = draw

   c.a1 = vector.new({p1[1], p1[2], p1[3]})
   c.a2 = vector.new({p2[1], p1[2], p1[3]})
   c.a3 = vector.new({p2[1], p2[2], p1[3]})
   c.a4 = vector.new({p1[1], p2[2], p1[3]})

   c.a5 = vector.new({p1[1], p1[2], p2[3]})
   c.a6 = vector.new({p2[1], p1[2], p2[3]})
   c.a7 = vector.new({p2[1], p2[2], p2[3]})
   c.a8 = vector.new({p1[1], p2[2], p2[3]})

   c.lines = {}
   c.faces = {}

   addLine(c.lines, c.a1, c.a2)
   addLine(c.lines, c.a2, c.a3)
   addLine(c.lines, c.a3, c.a4)
   addLine(c.lines, c.a4, c.a1)

   addLine(c.lines, c.a5, c.a6)
   addLine(c.lines, c.a6, c.a7)
   addLine(c.lines, c.a7, c.a8)
   addLine(c.lines, c.a8, c.a5)

   addLine(c.lines, c.a1, c.a5)
   addLine(c.lines, c.a2, c.a6)
   addLine(c.lines, c.a3, c.a7)
   addLine(c.lines, c.a4, c.a8)

   addFace(c.faces, c.a1, c.a4, c.a3, c.a2)
   addFace(c.faces, c.a6, c.a5, c.a1, c.a2)
   addFace(c.faces, c.a7, c.a6, c.a2, c.a3)
   addFace(c.faces, c.a8, c.a7, c.a3, c.a4)
   addFace(c.faces, c.a5, c.a8, c.a4, c.a1)
   addFace(c.faces, c.a7, c.a8, c.a5, c.a6)

   return c
end

M.new = new

return M
