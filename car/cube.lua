local vector = require("vector")
local geometry = require("geometry")

local M = {}

local function addLine(lines, color, a, b)
   local line = {vertices = {a, b}, color = color}
   table.insert(lines, {a, b})
end

local function addFace(faces, color, ...)
   local vertices = {...}
   local normal = geometry.normal(vertices)
   local centroid = geometry.centroid(vertices)
   local face = {vertices = vertices, normal = normal, centroid = centroid, color = color}
   table.insert(faces, face)
end

local function drawk(self, canvas3d)
   for _, line in ipairs(self.lines) do
      love.graphics.setColor(line.color)
      canvas3d:line(line.points[1], line.points[2])
   end
end

local function draw(self, canvas3d)
   for _, face in ipairs(self.faces) do
      canvas3d:polygon("fill", face)
   end
end

local function new(color, p1, p2)
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

   addLine(c.lines, color, c.a1, c.a2)
   addLine(c.lines, color, c.a2, c.a3)
   addLine(c.lines, color, c.a3, c.a4)
   addLine(c.lines, color, c.a4, c.a1)

   addLine(c.lines, color, c.a5, c.a6)
   addLine(c.lines, color, c.a6, c.a7)
   addLine(c.lines, color, c.a7, c.a8)
   addLine(c.lines, color, c.a8, c.a5)

   addLine(c.lines, color, c.a1, c.a5)
   addLine(c.lines, color, c.a2, c.a6)
   addLine(c.lines, color, c.a3, c.a7)
   addLine(c.lines, color, c.a4, c.a8)

   addFace(c.faces, color, c.a1, c.a4, c.a3, c.a2)
   addFace(c.faces, color, c.a6, c.a5, c.a1, c.a2)
   addFace(c.faces, color, c.a7, c.a6, c.a2, c.a3)
   addFace(c.faces, color, c.a8, c.a7, c.a3, c.a4)
   addFace(c.faces, color, c.a5, c.a8, c.a4, c.a1)
   addFace(c.faces, color, c.a7, c.a8, c.a5, c.a6)

   return c
end

M.new = new

return M
