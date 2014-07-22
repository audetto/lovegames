local C = require("constants")
local A = require("autoplay")

local M = {}


local function player_draw(self)
   love.graphics.setColor(self.color)
   love.graphics.push()
   love.graphics.translate(self.x, self.y)
   love.graphics.rotate(self.angle)
   love.graphics.rectangle('fill', -self.height / 2, 0, self.height, self.width)
   love.graphics.pop()

   local t = self.targets
   if t then
      for _, o in ipairs(t) do
	 love.graphics.circle('fill', o.x, o.y, 10, 10)
      end
   end
end


local function player_update(self, dt, game)
   local ball = game.ball

   if self.auto then
      -- we go towards the ball if it coming toward us, otherwise we go to rest position
      local towards_us = ball.speed.x * (ball.x - self.x) > 0
      local target_x = towards_us and self.home_x or ball.x
      local s_x = (target_x - self.x) / dt
      local s_y = (ball.y - self.y) / dt

      self.speed.x = bound(s_x, -C.PADDLE_SPEED, C.PADDLE_SPEED)
      self.speed.y = bound(s_y, -C.PADDLE_SPEED, C.PADDLE_SPEED)
   else
      local coeff_x = 0
      local coeff_y = 0

      if self.joystick then
	 coeff_x = self.joystick:getAxis(1)
	 coeff_y = self.joystick:getAxis(2)
	 self.angle = (self.joystick:getAxis(3) * 0.9 + 1) * math.pi / 2
      elseif love.keyboard.isDown(self.keys.up) then
	 coeff_y = -1
      elseif love.keyboard.isDown(self.keys.down) then
	 coeff_y = 1
      elseif love.keyboard.isDown(self.keys.left) then
	 coeff_x = -1
      elseif love.keyboard.isDown(self.keys.right) then
	 coeff_x = 1
      end

      self.speed.x = coeff_x * C.PADDLE_SPEED
      self.speed.y = coeff_y * C.PADDLE_SPEED
   end

   self.x = self.x + self.speed.x * dt
   self.y = self.y + self.speed.y * dt
   self.x = bound(self.x, self.min_x, self.max_x)
   self.y = bound(self.y, self.min_y, self.max_y)
end


local function player_keypressed(self, key)
   if key == self.keys.clock then
      self.angle = self.angle + 0.1
   elseif key == self.keys.anti then
      self.angle = self.angle - 0.1
   elseif key == self.keys.auto then
      self.auto = not self.auto
   else
      -- not processed
      return false
   end
   -- processed
   return true
end


local function player_autoplay(self, ball)
   if self.auto then
      self.targets = A.target(ball, self)
   else
      self.targets = nil
   end
end


function M.new()
   local p = {}
   p.auto = false
   p.points = 0
   p.speed = {}
   p.speed.x = 0
   p.speed.y = 0
   p.height = C.PADDLE_HEIGHT
   p.angle = math.pi / 2
   p.keys = {}
   p.target = {}

   p.update = player_update
   p.draw = player_draw
   p.keypressed = player_keypressed
   p.autoplay = player_autoplay
   return p
end


return M
