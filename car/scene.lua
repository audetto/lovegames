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

local function addVertexLines(self, vertices, indexLines)
   local lines = {}
   for _, indexLine in ipairs(indexLines) do
      local indexVertices = indexLine.vertices
      local color = indexLine.color

      local lineVertices = resolve(vertices, indexVertices)
      local centroid = geometry.centroid(lineVertices)

      local line = {vertices = indexVertices, centroid = centroid, color = color}
      table.insert(lines, line)
   end
   lines.vertices = vertices

   table.insert(self.vertexLines, lines)
end

local function addScene(self, scene)
   table.insert(self.scenes, scene)
end

local function draw(self, canvas3d)
   canvas3d:push(self.transformation.rotation)

   for _, lines in ipairs(self.vertexLines) do
      canvas3d:vertexLines(lines)
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

   for _, faces in ipairs(self.vertexArray) do
      local vertices = faces.vertices
      transformVertices(vertices, self.transformation)

      for _, face in ipairs(faces) do
	 local indexVertices = face.vertices

	 local faceVertices = resolve(vertices, indexVertices)
	 local normal = geometry.normal(faceVertices)
	 local centroid = geometry.centroid(faceVertices)

	 face.normal = normal
	 face.centroid = centroid
      end
   end

   for _, lines in ipairs(self.vertexLines) do
      local vertices = lines.vertices
      transformVertices(vertices, self.transformation)

      for _, line in ipairs(lines) do
	 local indexVertices = line.vertices

	 local lineVertices = resolve(vertices, indexVertices)
	 local centroid = geometry.centroid(lineVertices)

	 line.centroid = centroid
      end
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
   c.scenes = {}
   c.vertexArray = {}
   c.vertexLines = {}
   c.transformation = transformation.new()

   c.draw = draw
   c.addVertexLines = addVertexLines
   c.addVertexArray = addVertexArray
   c.addScene = addScene

   c.translate = translate
   c.rotate = rotate
   c.scale = scale
   c.apply = apply

   return c
end

M.new = new
M.newLine = newLine

return M
