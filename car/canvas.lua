local vector = require("vector")
local matrix = require("matrix")

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

local function line(self, theLine)
   local vertices = theLine.vertices
   local pa, pb = self.perspective:line(vertices[1], vertices[2])

   if pa and pb then
      local ax, ay = self:convert(pa)
      local bx, by = self:convert(pb)

      local rotatedCentroid = self:transform(theLine.centroid)

      local dist = rotatedCentroid:norm()
      table.insert(self.buffer, {dist = dist, action = function ()
				    love.graphics.setColor(theLine.color)
				    love.graphics.line(ax, ay, bx, by)
						       end
      })
   end
end

local function lines(self, theLines)
   for _, theLine in ipairs(theLines) do
      self:line(theLine)
   end
end

local function transform(self, x)
   return matrix.mulmv(self.current, x)
end

local function polygon(self, mode, face)
   local vertices = face.vertices

   local rotatedCentroid = self:transform(face.centroid)
   local rotatedNormal = self:transform(face.normal) -- normal[4] = 0!!!

   -- "-" as centroid is upside down
   local cos = -vector.cosangle(rotatedCentroid, rotatedNormal)

   if cos < self.cosThreshold then
      -- we cannot see the face
      return
   end

   local points = {}
   local n = #vertices
   local prev = vertices[n]

   for i = 1, n do
      local current = vertices[i]
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
				    love.graphics.polygon(mode, points)
						       end
      })
   end
end

local function vertexArray(self, vertexArray)
   local vertices = vertexArray.vertices

   local projectedVertices = {}
   for i, vertex in ipairs(vertices) do
      local p, r = self.perspective:projection(vertex)
      projectedVertices[i] = {p, r}
   end

   for _, face in ipairs(vertexArray) do
      local rotatedCentroid = self:transform(face.centroid)
      local rotatedNormal = self:transform(face.normal) -- normal[4] = 0!!!

      -- "-" as centroid is upside down
      local cos = -vector.cosangle(rotatedCentroid, rotatedNormal)

      if cos >= self.cosThreshold then
	 local indexVertices = face.vertices

	 local points = {}
	 local n = #indexVertices
	 local prev = projectedVertices[indexVertices[n]]

	 for i = 1, n do
	    local current = projectedVertices[indexVertices[i]]

	    local pa, pb, orga, _ = self.perspective:line2(prev, current)

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

local function push(self, mat)
   local last = #self.matrices
   self.current = matrix.mulmm(self.matrices[last], mat)
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
   c.matrices = { matrix.id() }

   c.perspective = perspective
   c.convert = convert
   c.line = line
   c.lines = lines
   c.polygon = polygon
   c.vertexArray = vertexArray
   c.addPoint = addPoint
   c.transform = transform
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
