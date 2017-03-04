local M = {}

local function convert(self, point)
   local x = self.width / 2 + point.x * self.scale
   local y = self.height / 2 - point.z * self.scale
   return x, y
end

local function line(self, a, b)
   local pa, pb = self.perspective:line(a, b)

   if pa and pb then
      local ax, ay = self:convert(pa)
      local bx, by = self:convert(pb)

      love.graphics.line(ax, ay, bx, by)
   end
end

local function new(perspective, scale)
   local c = {}

   c.perspective = perspective
   c.convert = convert
   c.line = line

   c.scale = scale
   c.width = love.graphics.getWidth()
   c.height = love.graphics.getHeight()

   return c
end

M.new = new

return M
