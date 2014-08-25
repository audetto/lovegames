local Player = require("player")
local Ball = require("ball")
local C = require("constants")
local Goal = require("goal")

local M = {}

local function game_setup(self)
   local ball = self.ball
   local player_1 = self.player_1
   local player_2 = self.player_2

   -- to alternate who gets the ball
   -- -1,1 mapped to 0,math.pi/2
   self.heads_tails = 1

   self.width = love.graphics.getWidth()
   self.height = love.graphics.getHeight()

   -- 100 pixels are the "goal" zone on each side
   self.min_of_game = 100
   self.max_of_game = self.width - self.min_of_game

   ball.color = {204, 204, 0}
   ball.min_x = self.min_of_game
   ball.max_x = self.max_of_game
   ball.min_y = ball.r
   ball.max_y = self.height - self.ball.r

   -- player 1
   player_1.color = {255, 0, 0}
   player_1.x = self.min_of_game
   player_1.y = self.height / 2
   player_1.min_y = 0
   player_1.max_y = self.height
   player_1.min_x = self.min_of_game
   player_1.max_x = self.width / 2
   player_1.home_x = player_1.min_x
   player_1.center_x = player_1.max_x
   player_1.width = C.PADDLE_WIDTH

   player_1.keys.up = "w"
   player_1.keys.down = "s"
   player_1.keys.left = "a"
   player_1.keys.right = "d"
   player_1.keys.clock = "x"
   player_1.keys.anti = "z"
   player_1.keys.auto = "q"

   -- player 2
   player_2.color = {0, 255, 0}
   player_2.x = self.max_of_game
   player_2.y = self.height / 2
   player_2.min_y = 0
   player_2.max_y = self.height
   player_2.min_x = self.width / 2
   player_2.max_x = self.max_of_game
   player_2.home_x = player_2.max_x
   player_2.center_x = player_2.min_x
   player_2.width = -C.PADDLE_WIDTH

   player_2.keys.up = "i"
   player_2.keys.down = "k"
   player_2.keys.left = "j"
   player_2.keys.right = "l"
   player_2.keys.clock = "m"
   player_2.keys.anti = "n"
   player_2.keys.auto = "p"

   -- font and points
   local font = love.graphics.newFont(40)
   love.graphics.setFont(font)

   -- love 8 compatibility
   local getJoysticks = love.joystick.getJoysticks
   local joysticks = getJoysticks and getJoysticks()
   player_2.joystick = joysticks and joysticks[1]

   self.objects = {}
   self.objects[1] = self.goal
   self.objects[2] = self.ball
   self.objects[3] = self.player_1
   self.objects[4] = self.player_2

   -- reset
   self:restart()
end


local function game_restart(self)
   local ball = self.ball
   local player_1 = self.player_1
   local player_2 = self.player_2

   -- ball in the centre
   ball.x = (self.min_of_game + self.max_of_game) / 2
   ball.y = self.height / 2

   -- points per second
   local ball_speed = C.BALL_INITIAL_SPEED
   local ball_angle = (math.random() - 0.5) * math.pi / 2

   -- so we alternate who gets the ball first
   ball_angle = ball_angle + (self.heads_tails + 1) * math.pi / 2
   self.heads_tails = -self.heads_tails

   ball.alive = true
   ball.speed.x = ball_speed * math.cos(ball_angle)
   ball.speed.y = ball_speed * math.sin(ball_angle)
   ball.speed.abs = ball_speed

   love.event.push('newball')
end


local function game_draw_court(self)
   local player_1 = self.player_1
   local player_2 = self.player_2
   local ball = self.ball

   local center_x = self.width / 2
   local center_y = self.height / 2

   -- court
   love.graphics.setColor(255, 255, 0)
   love.graphics.line(self.min_of_game, 0, self.min_of_game, self.height)
   love.graphics.line(self.max_of_game, 0, self.max_of_game, self.height)
   love.graphics.line(center_x, self.height * 2 / 5, center_x, self.height * 3 / 5)
   love.graphics.rectangle('line', 0, 0, self.width, self.height)
   love.graphics.circle('line', center_x, center_y, 10, 10)

   -- points
   love.graphics.setColor(123, 204, 40)
   love.graphics.printf(player_1.points .. " : " .. player_2.points, 0, 50, self.width, 'center')

   -- speeds
   local bar = 200
   local left_x = center_x - bar / 2
   local up_y = self.height - 50
   local pos = ball.speed.abs / C.BALL_INITIAL_SPEED * bar
   local min = C.BALL_MINIMUM_SPEED / C.BALL_INITIAL_SPEED * bar

   love.graphics.setColor(0, 255, 255)
   love.graphics.rectangle('fill', left_x, up_y, pos, 10)

   love.graphics.setColor(255, 0, 0)
   love.graphics.rectangle('fill', left_x, up_y, min, 10)

   love.graphics.setColor(255, 255, 255)
   love.graphics.rectangle('line', left_x, up_y, bar, 10)
end


local function game_update(self, dt)
   for _, o in ipairs(self.objects) do
      local f = o.update
      if f then
	 if f(o, dt, self) then
	    -- a restart needs to be called
	    self:restart()
	    return
	 end
      end
   end
end


local function game_draw(self)
   love.graphics.setBackgroundColor(0, 0, 200)

   -- here must draw goal first
   -- otherwise all effects are applied in random order
   for _, o in ipairs(self.objects) do
      local f = o.draw
      if f then
	 f(o)
      end
   end

   -- draw it at the end as goal must be first!
   self:draw_court()

end


local function game_keypressed(self, key)
   for _, o in ipairs(self.objects) do
      local f = o.keypressed
      if f then
	 if f(o, key) then
	    -- done event processed: return
	    return
	 end
      end
   end
end


local function game_bounce(self, ball, player)
   for _, o in ipairs(self.objects) do
      local f = o.bounce
      if f then
	 f(o, ball, player)
      end
   end
end


local function game_newball(self, ball)
   for _, o in ipairs(self.objects) do
      local f = o.newball
      if f then
	 f(o, ball)
      end
   end
end


function M.new()
   local g = {}
   g.player_1 = Player.new("autoplay")
   g.player_2 = Player.new("autoplay")

   g.ball = Ball.new()
   g.goal = Goal.new()

   g.setup = game_setup
   g.restart = game_restart
   g.draw_court = game_draw_court
   g.draw = game_draw
   g.keypressed = game_keypressed
   g.update = game_update

   g.bounce = game_bounce
   g.newball = game_newball

   return g
end

return M
