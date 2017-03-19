local vector = require("vector")
local matrix = require("matrix")
local geometry = require("geometry")

local M = {}

local function translateVertices(vertices, translation)
   for i, vertex in ipairs(vertices) do
      vertices[i] = vector.add(vertex, 1, translation)
   end
end

local function rotateVertices(vertices, rotation)
   for i, vertex in ipairs(vertices) do
      vertices[i] = matrix.mulmv(rotation, vertex)
   end
end

local function newLine(color, a, b, relative)
   local vertices = {a, b}
   local centroid = geometry.centroid(vertices)
   local line = {vertices = vertices, centroid = centroid, color = color, relative = relative}
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
   for _, line in ipairs(self.lines) do
      canvas3d:line(line)
   end

   for _, face in ipairs(self.faces) do
      canvas3d:polygon("fill", face)
   end
end

local function translate(self, translation)
   for _, line in ipairs(self.lines) do
      translateVertices(line.vertices, translation)
      line.centroid = geometry.centroid(line.vertices)
   end

   for _, face in ipairs(self.faces) do
      translateVertices(face.vertices, translation)
      face.normal = geometry.normal(face.vertices)
      face.centroid = geometry.centroid(face.vertices)
   end
end

local function rotate(self, rotation)
   for _, line in ipairs(self.lines) do
      rotateVertices(line.vertices, rotation)
      line.centroid = geometry.centroid(line.vertices)
   end

   for _, face in ipairs(self.faces) do
      rotateVertices(face.vertices, rotation)
      face.normal = geometry.normal(face.vertices)
      face.centroid = geometry.centroid(face.vertices)
   end
end

local function new()
   local c = {}
   c.draw = draw

   c.lines = {}
   c.faces = {}

   c.addLine = addLine
   c.addFace = addFace
   c.translate = translate
   c.rotate = rotate

   return c
end

M.new = new
M.newLine = newLine

return M
