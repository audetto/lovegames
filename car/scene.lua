local vector = require("vector")
local matrix = require("matrix")
local geometry = require("geometry")
local transformation = require("transformation")

local M = {}

local function transformVertices(vertices, transformation)
   for i, vertex in ipairs(vertices) do
      vertices[i] = transformation:transform(vertex)
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

local function resolve(vertices, indexFace)
   local face = {}
   for i, indexVertex in ipairs(indexFace) do
      face[i] = vertices[indexVertex]
   end
   return face
end

local function addVertexArray(self, vertices, indexFaces)
   local faces = {}
   for _, indexFace in ipairs(indexFaces) do
      local indexVertices = indexFace.vertices
      local color = indexFace.color

      local faceVertices = resolve(vertices, indexVertices)
      local normal = geometry.normal(faceVertices)
      local centroid = geometry.centroid(faceVertices)

      local face = {vertices = indexVertices, normal = normal, centroid = centroid, color = color}
      table.insert(faces, face)
   end
   faces.vertices = vertices

   table.insert(self.vertexArray, faces)
end

local function addScene(self, scene)
   table.insert(self.scenes, scene)
end

local function draw(self, canvas3d)
   canvas3d:push(self.transformation.rotation)

   for _, line in ipairs(self.lines) do
      canvas3d:line(line)
   end

   for _, face in ipairs(self.faces) do
      canvas3d:polygon("fill", face)
   end

   for _, faces in ipairs(self.vertexArray) do
      canvas3d:vertexArray(faces)
   end

   for _, scene in ipairs(self.scenes) do
      scene:draw(canvas3d)
   end

   canvas3d:pop()
end

local function translate(self, ...)
   self.transformation:translate(...)
end

local function rotate(self, ...)
   self.transformation:rotate(...)
end

local function scale(self, ...)
   self.transformation:scale(...)
end

local function apply(self)
   for _, line in ipairs(self.lines) do
      transformVertices(line.vertices, self.transformation)
      line.centroid = geometry.centroid(line.vertices)
   end

   for _, face in ipairs(self.faces) do
      transformVertices(face.vertices, self.transformation)
      face.normal = geometry.normal(face.vertices)
      face.centroid = geometry.centroid(face.vertices)
   end

   for _, scene in ipairs(self.scenes) do
      scene.transformation:generic(self.transformation.rotation)
   end

   -- reset
   self.transformation = transformation.new()
end

local function new()
   local c = {}

   c.lines = {}
   c.faces = {}
   c.scenes = {}
   c.vertexArray = {}
   c.transformation = transformation.new()

   c.draw = draw
   c.addLine = addLine
   c.addFace = addFace
   c.addScene = addScene
   c.addVertexArray = addVertexArray
   c.translate = translate
   c.rotate = rotate
   c.scale = scale
   c.apply = apply

   return c
end

M.new = new
M.newLine = newLine

return M
