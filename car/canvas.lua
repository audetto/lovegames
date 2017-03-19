local vector = require("vector")

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
   local relative = theLine.relative
   local pa, pb = self.perspective:line(vertices[1], vertices[2], relative)

   if pa and pb then
      local ax, ay = self:convert(pa)
      local bx, by = self:convert(pb)

      local centroid = theLine.centroid
      local camera = self.perspective.camera.translation

      local connecting = (relative and centroid) or vector.add(camera, -1, centroid)

      local dist = connecting:norm()
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

local function polygon(self, mode, face)
   local vertices = face.vertices
   local points = {}
   local n = #vertices
   local prev = vertices[n]

   local centroid = face.centroid
   local normal = face.normal
   local camera = self.perspective.camera.translation

   local connecting = vector.add(camera, -1, centroid)

   local cos = vector.cosangle(connecting, normal)

   if cos < self.cosThreshold then
      -- we cannot see the face
      return
   end

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
      local dist = connecting:norm()
      table.insert(self.buffer, {dist = dist, action = function ()
				    love.graphics.setColor(face.color[1] * cos, face.color[2] * cos, face.color[3] * cos)
				    love.graphics.polygon(mode, points)
						       end
      })
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


local function new(perspective, scale)
   local c = {}

   c.buffer = {}
   c.cosThreshold = 0.01
   c.perspective = perspective
   c.convert = convert
   c.line = line
   c.lines = lines
   c.polygon = polygon
   c.addPoint = addPoint
   c.draw = draw

   c.scale = scale
   c.width = love.graphics.getWidth()
   c.height = love.graphics.getHeight()

   return c
end

M.new = new

return M
