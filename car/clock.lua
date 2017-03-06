local colors = require("colors")
local torch = require("torch")

local M = {}

local function draw_line(self, canvas, angle, ratio)
   local rad = math.pi * (0.5 - 2 * angle)
   local x = math.cos(rad) * ratio * self.size
   local z = math.sin(rad) * ratio * self.size

   local a = self.position

   local b = torch.Tensor({a[1] + x, a[2], a[3] + z})
   canvas:line(a, b)
end

local function draw(self, canvas)
   local a = os.date("*t")

   local angle_seconds = a.sec / 60
   love.graphics.setColor(colors.lime)
   self:draw_line(canvas, angle_seconds, 0.9)

   local angle_minutes = (a.min + angle_seconds) / 60
   love.graphics.setColor(colors.blue)
   self:draw_line(canvas, angle_minutes, 0.8)

   local angle_hours = ((a.hour + 12) + angle_minutes) / 12
   love.graphics.setColor(colors.red)
   self:draw_line(canvas, angle_hours, 0.5)

   love.graphics.setColor(colors.olive)
   for i = 1, self.steps do
      canvas:line(self.border[i], self.border[i + 1])
   end

end

function M.new(position, size)
   local p = {}

   p.steps = 40
   p.position = position
   p.size = size
   p.draw = draw
   p.draw_line = draw_line

   p.border = {}

   for i = 1, p.steps do
      local rad = math.pi * 2 / p.steps * i
      local x = math.cos(rad) * p.size
      local z = math.sin(rad) * p.size

      local b = torch.Tensor({p.position[1] + x, p.position[2], p.position[3] + z})

      table.insert(p.border, b)
   end
   table.insert(p.border, p.border[1])

   return p
end

return M
