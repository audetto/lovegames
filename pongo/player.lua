local C = require("constants")

local M = {}


local function player_draw(self)
   love.graphics.setColor(self.color)
   love.graphics.push()
   love.graphics.translate(self.x, self.y)
   love.graphics.rotate(self.angle)
   love.graphics.rectangle('fill', -self.height / 2, 0, self.height, self.width)
   love.graphics.pop()

   local t = self.target
   if t then
      love.graphics.circle('line', t.x, t.y, C.BALL_RADIUS, 10)
   end
end


local function player_update(self, dt, game)
   local ball = game.ball

   if self.auto then
      self.target = self.autoplay.update(self, ball, self.target)
      local t = self.target
      if t then
	 -- with dt, we get there as fast as possible (i.e. in 1 frame)
	 local target_time
	 if t.t then
	    target_time = t.t
	    -- for next time
	    t.t = target_time - dt
	 else
	    target_time = dt
	 end

	 -- if target_time <= 0, it means we got there too early
	 -- just keep going... so the impact will have some speed
	 if target_time > 0 then
	    local sx = (t.x - self.x) / target_time
	    local sy = (t.y - self.y) / target_time

	    local speed = math.sqrt(sx * sx + sy * sy)
	    if speed > C.PADDLE_SPEED then
	       local ratio = C.PADDLE_SPEED / speed
	       sx = sx * ratio
	       sy = sy * ratio
	    end

	    self.speed.x = sx
	    self.speed.y = sy
	 end

	 self.angle = t.angle or self.angle
      end
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


local function player_bounce(self, ball, player)
   if self.auto then
      self.target = self.autoplay.bounce(self, ball)
   else
      self.target = nil
   end
end


local function player_newball(self, ball)
   self.collision = false

   if self.auto then
      self.target = self.autoplay.bounce(self, ball)
   else
      self.target = nil
   end
end


function M.new(strategy)
   local p = {}
   p.auto = false
   p.points = 0
   p.speed = {}
   p.speed.x = 0
   p.speed.y = 0
   p.height = C.PADDLE_HEIGHT
   p.angle = math.pi / 2
   p.keys = {}

   local st = require(strategy)
   p.autoplay = {}
   p.autoplay.bounce = st.bounce
   p.autoplay.update = st.update

   p.update = player_update
   p.draw = player_draw
   p.keypressed = player_keypressed
   p.bounce = player_bounce
   p.newball = player_newball

   return p
end


return M
