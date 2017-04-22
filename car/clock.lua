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
   self.border:draw(canvas)

   local a = os.date("*t")

   local angle_seconds = a.sec / 60
   canvas:line(self:createLine(colors.lime, angle_seconds, 0.9))

   local angle_minutes = (a.min + angle_seconds) / 60
   canvas:line(self:createLine(colors.blue, angle_minutes, 0.8))

   local angle_hours = ((a.hour + 12) + angle_minutes) / 12
   canvas:line(self:createLine(colors.red, angle_hours, 0.5))
end

function M.new(position, size)
   local p = {}

   p.steps = 12
   p.position = position
   p.size = size
   p.draw = draw
   p.createLine = createLine
   p.border = scene:new()

   local vertices = {}
   local indexLines = {}

   for i = 1, p.steps do
      local rad = math.pi * 2 / p.steps * i
      local x = math.cos(rad) * p.size
      local z = math.sin(rad) * p.size

      local b = vector.new({p.position[1] + x, p.position[2], p.position[3] + z})

      table.insert(vertices, b)

      local prev = (i == 1) and p.steps or (i - 1)
      table.insert(indexLines, {vertices = {prev, i}, color = colors.olive})
   end

   p.border:addVertexLines(vertices, indexLines)

   return p
end

return M
