local M = {}

local function ball_draw(self)
   love.graphics.setColor(self.color)
   love.graphics.circle('fill', self.x, self.y, self.r, 10)
end

local function ball_update(self, dt)
   self.x = self.x + self.speed.x * dt
   self.y = self.y + self.speed.y * dt
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
