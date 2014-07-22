local C = require("constants")

local M = {}

local function ball_draw(self)
   if self.help then
      love.graphics.setColor(255, 218, 185)
      local dt = 1 -- 1 sec ahead
      love.graphics.line(self.x, self.y, self.x + self.speed.x * dt, self.y + self.speed.y * dt)
   end

   love.graphics.setColor(self.color)
   love.graphics.circle('fill', self.x, self.y, self.r, C.BALL_RADIUS)
end

local function ball_update(self, dt, game)
   local player_1 = game.player_1
   local player_2 = game.player_2

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

   -- bounce up and down
   if self.y < self.min_y or self.y > self.max_y then
      -- no random angle added here
      self.speed.y = -self.speed.y
      self.y = bound(self.y, self.min_y, self.max_y)
   end

   if collision(self, player_2) then
      bounce(self, player_2, C.RANDOM_ANGLE)
      player_1:autoplay(self)
   elseif collision(self, player_1) then
      bounce(self, player_1, C.RANDOM_ANGLE)
      player_2:autoplay(self)
   elseif self.x > self.max_x then
      point(player_1)
      return true
   elseif self.x < self.min_x then
      point(player_2)
      return true
   end

   if not self.alive then
      -- too slow: end of point
      if self.x < game.width / 2 then
	 -- player 1 court -> point to 2
	 point(player_2)
      else
	 -- player 2 court -> point to 1
	 point(player_1)
      end
      return true
   end

end

local function ball_keypressed(self, key)
   if key == "h" then
      self.help = not self.help
   else
      return false
   end
   return true
end


function M.new()
   local b = {}
   b.alive = true
   b.help = false
   b.r = C.BALL_RADIUS
   b.speed = {}
   b.speed.x = 0
   b.speed.y = 0

   b.update = ball_update
   b.draw = ball_draw
   b.keypressed = ball_keypressed
   return b
end


return M
