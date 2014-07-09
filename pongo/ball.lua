local C = require("constants")

local M = {}

local function ball_draw(self)
   love.graphics.setColor(self.color)
   love.graphics.circle('fill', self.x, self.y, self.r, C.BALL_RADIUS)
end

local function ball_update(self, dt)
   local s_x = self.speed.x
   local s_y = self.speed.y

   self.x = self.x + s_x * dt
   self.y = self.y + s_y * dt

   local speed = math.sqrt(s_x * s_x + s_y * s_y)
   self.alive = speed > C.BALL_MINIMUM_SPEED

   -- we will loose C.BALL_DECELERATION speed per second
   local coeff = 1 - C.BALL_DECELERATION * dt / speed
   self.speed.x = s_x * coeff
   self.speed.y = s_y * coeff
end


function M.new()
   b = {}
   b.alive = true
   b.r = C.BALL_RADIUS
   b.speed = {}
   b.speed.x = 0
   b.speed.y = 0

   b.update = ball_update
   b.draw = ball_draw
   return b
end


return M
