local vector = require("vector")
local matrix = require("matrix")
local geometry = require("geometry")
local transformation = require("transformation")

local M = {}

local function transformVertices(vertices, rotation)
   for i, vertex in ipairs(vertices) do
      vertices[i] = matrix.mulmv(rotation, vertex)
   end
end

local function newLine(color, a, b)
   local vertices = {a, b}
   local centroid = geometry.centroid(vertices)
   local line = {vertices = vertices, centroid = centroid, color = color}
   return line
end

local function addLine(self, ...)
   local line = newLine(...)
   table.insert(self.lines, line)
end

local function addFace(self, color, ...)
   local vertices = {...}
   local normal = geometry.normal(vertices)
   local centroid = geometry.centroid(vertices)
   local face = {vertices = vertices, normal = normal, centroid = centroid, color = color}
   table.insert(self.faces, face)
end

local function draw(self, canvas3d)
   canvas3d:push(self.transformation.rotation)

   for _, line in ipairs(self.lines) do
      canvas3d:line(line)
   end

   for _, face in ipairs(self.faces) do
      canvas3d:polygon("fill", face)
   end

   canvas3d:pop()
end

local function translate(self, translation)
   self.transformation:translate(translation, 1)
end

local function rotate(self, rotation)
   self.transformation:generic(rotation)
end

local function apply(self)
   for _, line in ipairs(self.lines) do
      transformVertices(line.vertices, self.transformation.rotation)
      line.centroid = geometry.centroid(line.vertices)
   end

   for _, face in ipairs(self.faces) do
      transformVertices(face.vertices, self.transformation.rotation)
      face.normal = geometry.normal(face.vertices)
      face.centroid = geometry.centroid(face.vertices)
   end

   -- reset
   self.transformation = transformation.new()
end

local function new()
   local c = {}
   c.draw = draw

   c.lines = {}
   c.faces = {}
   c.transformation = transformation.new()

   c.addLine = addLine
   c.addFace = addFace
   c.translate = translate
   c.rotate = rotate
   c.apply = apply

   return c
end

M.new = new
M.newLine = newLine

return M
