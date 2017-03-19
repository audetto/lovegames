local colors = require("colors")
local vector = require("vector")
local scene = require("scene")

local M = {}

local function createLine(self, color, angle, ratio)
   local rad = math.pi * (0.5 - 2 * angle)
   local x = math.cos(rad) * ratio * self.size
   local z = math.sin(rad) * ratio * self.size

   local a = self.position

   local b = vector.new({a[1] + x, a[2], a[3] + z})

   local line = scene.newLine(color, a, b)
   return line
end

local function draw(self, canvas)
   canvas:lines(self.lines)

   local lines = {}

   local a = os.date("*t")

   local angle_seconds = a.sec / 60
   table.insert(lines, self:createLine(colors.lime, angle_seconds, 0.9))

   local angle_minutes = (a.min + angle_seconds) / 60
   table.insert(lines, self:createLine(colors.blue, angle_minutes, 0.8))

   local angle_hours = ((a.hour + 12) + angle_minutes) / 12
   table.insert(lines, self:createLine(colors.red, angle_hours, 0.5))

   canvas:lines(lines)
end

function M.new(position, size)
   local p = {}

   p.steps = 12
   p.position = position
   p.size = size
   p.draw = draw
   p.createLine = createLine

   local border = {}

   for i = 1, p.steps do
      local rad = math.pi * 2 / p.steps * i
      local x = math.cos(rad) * p.size
      local z = math.sin(rad) * p.size

      local b = vector.new({p.position[1] + x, p.position[2], p.position[3] + z})

      table.insert(border, b)
   end
   table.insert(border, border[1])

   p.lines = {}

   for i = 1, p.steps do
      local line = scene.newLine(colors.olive, border[i], border[i + 1])
      table.insert(p.lines, line)
   end

   return p
end

return M
