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

local function ball_keypressed(self, key)
   if key == "up" then
      self.speed = self.speed + 10
   elseif key == "down" then
      self.speed = self.speed - 10
   else
      return true
   end
end

function M.new(b)
   b.update = ball_update
   b.draw = ball_draw
   b.keypressed = ball_keypressed
   return b
end


return M
