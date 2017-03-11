local M = {}

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

local function polygon(self, mode, vertices)
   local points = {}
   local n = #vertices
   local prev = vertices[n]

   for i = 1, n do
      local current = vertices[i]
      local pa, pb = self.perspective:line(prev, current)
      if pa and pb then
	 local bx, by = self:convert(pb)

	 table.insert(points, bx)
	 table.insert(points, by)
      end
   end

   if #points > 4 then
      love.graphics.polygon(mode, table.unpack(points))
   end
end

local function new(perspective, scale)
   local c = {}

   c.perspective = perspective
   c.convert = convert
   c.line = line
   c.lines = lines
   c.polygon = polygon

   c.scale = scale
   c.width = love.graphics.getWidth()
   c.height = love.graphics.getHeight()

   return c
end

M.new = new

return M
