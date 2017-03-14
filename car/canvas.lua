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

local function line(self, a, b, relative)
   local pa, pb = self.perspective:line(a, b, relative)

   if pa and pb then
      local ax, ay = self:convert(pa)
      local bx, by = self:convert(pb)

      love.graphics.line(ax, ay, bx, by)
   end
end

local function lines(self, points)
   for _, value in ipairs(points) do
      if value.color then
	 love.graphics.setColor(value.color)
      end
      self:line(value.a, value.b, value.relative)
   end
end

local function polygon(self, mode, face)
   local vertices = face.vertices
   local points = {}
   local n = #vertices
   local prev = vertices[n]

   local centroid = face.centroid
   local normal = face.normal
   local eye = self.perspective.eye

   local connecting = vector.add(self.work, eye, -1, centroid)

   local cos = vector.cosangle(connecting, normal)

   if cos < self.cosThreshold then
      -- we cannot see the face
      return
   end

   love.graphics.setColor(face.color[1] * cos, face.color[2] * cos, face.color[3] * cos)

   for i = 1, n do
      local current = vertices[i]
      local pa, pb, orga, _ = self.perspective:line(prev, current)

      if pa and pb then
	 if not orga then
	    -- the a point has been modified
	    -- so it wont much the b point of the previous side
	    -- => we must inster it now
	    self:addPoint(points, pa)
	 end

	 -- b point is always inserted
	 self:addPoint(points, pb)
      end
      prev = current
   end

   if #points > 4 then
      love.graphics.polygon(mode, points)
   end
end

local function new(perspective, scale)
   local c = {}

   c.cosThreshold = 0.01
   c.work = vector.empty()
   c.perspective = perspective
   c.convert = convert
   c.line = line
   c.lines = lines
   c.polygon = polygon
   c.addPoint = addPoint

   c.scale = scale
   c.width = love.graphics.getWidth()
   c.height = love.graphics.getHeight()

   return c
end

M.new = new

return M
