local Player = require("player")
local Ball = require("ball")
local C = require("constants")
local Goal = require("goal")

local M = {}

local function game_setup(self)
   local ball = self.ball
   local player_1 = self.player_1
   local player_2 = self.player_2

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
   player_1.width = C.PADDLE_WIDTH

   player_1.keys.up = "w"
   player_1.keys.down = "s"
   player_1.keys.left = "a"
   player_1.keys.right = "d"
   player_1.keys.clock = "x"
   player_1.keys.anti = "z"
   player_1.keys.auto = "q"

   -- player 2
   player_2.color = {255, 255, 0}
   player_2.x = self.max_of_game
   player_2.y = self.height / 2
   player_2.min_y = 0
   player_2.max_y = self.height
   player_2.min_x = self.width / 2
   player_2.max_x = self.max_of_game
   player_2.home_x = player_2.max_x
   player_2.width = -C.PADDLE_WIDTH

   player_2.keys.up = "i"
   player_2.keys.down = "k"
   player_2.keys.left = "j"
   player_2.keys.right = "l"
   player_2.keys.clock = "m"
   player_2.keys.anti = "n"

   -- font and points

   local font = love.graphics.newFont(40)
   love.graphics.setFont(font)

   local joysticks = love.joystick.getJoysticks()
   player_2.joystick = joysticks[1]

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

   ball.alive = true
   ball.speed.x = ball_speed * math.cos(ball_angle)
   ball.speed.y = ball_speed * math.sin(ball_angle)

   -- reset collision
   player_1.collision = false
   player_2.collision = false
   -- leave players where they are

   -- done processing events
   return true
end


local function game_draw(self)
   local player_1 = self.player_1
   local player_2 = self.player_2

   -- court
   love.graphics.setColor(255, 255, 0)
   love.graphics.line(self.min_of_game, 0, self.min_of_game, self.height)
   love.graphics.line(self.max_of_game, 0, self.max_of_game, self.height)
   love.graphics.line(self.width / 2, self.height * 2 / 5 , self.width / 2, self.height * 3 / 5)
   love.graphics.rectangle('line', 0, 0, self.width, self.height)
   love.graphics.circle('line', self.width / 2, self.height / 2, 10, 10)

   -- points
   love.graphics.setColor(123, 204, 40)
   love.graphics.print(player_1.points .. " : " .. player_2.points, 300, 300)
end

function M.new()
   local g = {}
   g.player_1 = Player.new()
   g.player_2 = Player.new()

   g.ball = Ball.new()
   g.goal = Goal.new()

   g.setup = game_setup
   g.restart = game_restart
   g.draw = game_draw

   return g
end

return M
