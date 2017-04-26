local vector = require("vector")
local transformation = require("transformation")

local M = {}

local function addPoint(self, points, p)
   local x, y = self:convert(p)

   table.insert(points, x)
   table.insert(points, y)
end

local function convert(self, point)
   local x = self.width / 2 + point[1] * self.scale
   local y = self.height / 2 - point[2] * self.scale
   return x, y
end

-- a & b have alreday been projected
local function line2(self, a, b, line)
   local pa, pb = self.perspective:line(a, b)

   if pa and pb then
      local ax, ay = self:convert(pa)
      local bx, by = self:convert(pb)

      local rotatedCentroid = self.current:transform(line.centroid)

      local dist = rotatedCentroid:norm()
      table.insert(self.buffer, {dist = dist, action = function ()
				    love.graphics.setColor(line.color)
				    love.graphics.line(ax, ay, bx, by)
						       end
      })
   end
end

local function vertexLines(self, vertexLines)
   local vertices = vertexLines.vertices

   local projectedVertices = {}
   for i, vertex in ipairs(vertices) do
      projectedVertices[i] = self.perspective:projection(vertex)
   end

   for _, line in ipairs(vertexLines) do
      local indexVertices = line.vertices

      local a = projectedVertices[indexVertices[1]]
      local b = projectedVertices[indexVertices[2]]

      self:line2(a, b, line)
   end
end

local function line(self, theLine)
   local vertices = theLine.vertices

   local pa = self.perspective:projection(vertices[1])
   local pb = self.perspective:projection(vertices[2])

   self:line2(pa, pb, theLine)
end

local function vertexArray(self, vertexArray)
   local vertices = vertexArray.vertices

   local projectedVertices = {}
   for i, vertex in ipairs(vertices) do
      projectedVertices[i] = self.perspective:projection(vertex)
   end

   for _, face in ipairs(vertexArray) do
      local rotatedCentroid = self.current:transform(face.centroid)
      local rotatedNormal = self.current:transform(face.normal) -- normal[4] = 0!!!

      -- "-" as centroid is upside down
      local cos = -vector.cosangle(rotatedCentroid, rotatedNormal)

      if cos >= self.cosThreshold then
	 local indexVertices = face.vertices

	 local points = {}
	 local n = #indexVertices
	 local prev = projectedVertices[indexVertices[n]]

	 for i = 1, n do
	    local current = projectedVertices[indexVertices[i]]

	    local pa, pb, orga, _ = self.perspective:line(prev, current)

	    if pa and pb then
	       if not orga then
		  -- the a point has been modified
		  -- so it wont match the b point of the previous side
		  -- => we must insert it now
		  self:addPoint(points, pa)
	       end

	       -- b point is always inserted
	       self:addPoint(points, pb)
	    end
	    prev = current
	 end

	 if #points > 4 then
	    local dist = rotatedCentroid:norm()
	    table.insert(self.buffer, {dist = dist, action = function ()
					  love.graphics.setColor(face.color[1] * cos, face.color[2] * cos, face.color[3] * cos)
					  love.graphics.polygon("fill", points)
							     end
	    })
	 end

      end
   end
end

local function compare(x, y)
   -- draw more distant objects first
   return x.dist > y.dist
end

local function draw(self)
   table.sort(self.buffer, compare)
   for _, element in ipairs(self.buffer) do
      element.action()
   end
   self.buffer = {}
end

local function push(self, trans)
   local last = #self.matrices

   -- shllow copy
   self.current = self.current:clone()
   -- this will make it into a deep copy
   self.current:generic(trans)

   self.perspective:setCamera(self.current)
   self.matrices[last + 1] = self.current
end

local function pop(self)
   local last = #self.matrices
   self.matrices[last] = nil
   self.current = self.matrices[last - 1]
end

local function new(perspective, scale)
   local c = {}

   c.buffer = {}
   c.cosThreshold = 0.01
   c.current = transformation.new()
   c.matrices = { c.current }


   c.perspective = perspective
   c.convert = convert
   c.line2 = line2
   c.line = line
   c.vertexArray = vertexArray
   c.vertexLines = vertexLines
   c.addPoint = addPoint
   c.draw = draw
   c.push = push
   c.pop = pop

   c.scale = scale
   c.width = love.graphics.getWidth()
   c.height = love.graphics.getHeight()

   return c
end

M.new = new

return M
