local Player = require("player")
local Ball = require("ball")
local C = require("constants")
local Goal = require("goal")

-- this is the top left
local player_1 = Player.new()
local player_2 = Player.new()

-- this is the centre
-- global for now to be accessed by player
ball = Ball.new()

-- goal
local goal = Goal.new()

-- autoplay
local help_play = false

function bounce(ball, player, random_angle)
   -- first calculate ball speed wrt player
   local relative_x = ball.speed.x - player.speed.x
   local relative_y = ball.speed.y - player.speed.y

   -- compute current speed and angle
   local ball_angle = math.atan2(relative_y, relative_x)
   local ball_speed = math.sqrt(relative_x ^ 2 + relative_y ^ 2)

   -- bounce
   local new_angle = -ball_angle + 2 * player.angle
   local extra = (math.random() - 0.5) * random_angle
   new_angle = new_angle + extra

   -- reapply same speed to new angle + player speed
   ball.speed.x = ball_speed * math.cos(new_angle) + player.speed.x
   ball.speed.y = ball_speed * math.sin(new_angle) + player.speed.y
end


function bound(value, min, max)
   return math.min(math.max(value, min), max)
end


-- the collision is only wrt the main side of the paddle
-- so we are checking intersection between a segment of a line and a circle
function collision(ball, player)
   local m = math.tan(player.angle)
   local a = -m
   local b = 1
   local c = m * player.x - player.y

   local collision = false

   local dist_fromline = math.abs(a * ball.x + b * ball.y + c) / math.sqrt(a * a + b * b)
   if dist_fromline < ball.r then
      local dist_fromcentre = math.sqrt((player.x - ball.x) ^ 2 + (player.y - ball.y) ^ 2)
      if dist_fromcentre < (player.height / 2 + ball.r) then
	 collision = true
      end
   end

   -- after a collision we do not return an other collision
   -- until after a non collision has happened
   local old_collision = player.collision
   player.collision = collision

   return (not old_collision) and collision
end


function setup()
   -- 100 pixels are the "goal" zone on each side
   min_of_game = 100
   max_of_game = width - min_of_game

   ball.color = {204, 204, 0}
   ball.min_x = min_of_game
   ball.max_x = max_of_game
   ball.min_y = ball.r
   ball.max_y = height - ball.r

   -- player 1
   player_1.color = {255, 0, 0}
   player_1.x = min_of_game
   player_1.y = height / 2
   player_1.min_y = 0
   player_1.max_y = height
   player_1.min_x = min_of_game
   player_1.max_x = width / 2
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
   player_2.x = max_of_game
   player_2.y = height / 2
   player_2.min_y = 0
   player_2.max_y = height
   player_2.min_x = width / 2
   player_2.max_x = max_of_game
   player_2.home_x = player_2.max_x
   player_2.width = -C.PADDLE_WIDTH

   player_2.keys.up = "i"
   player_2.keys.down = "k"
   player_2.keys.left = "j"
   player_2.keys.right = "l"
   player_2.keys.clock = "m"
   player_2.keys.anti = "n"

   restart()
end


function restart()
   -- ball in the centre
   ball.x = (min_of_game + max_of_game) / 2
   ball.y = height / 2

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
end

function point(player)
   -- start goal effects
   goal:start()

   player.points = player.points + 1
end

function court_draw()
   love.graphics.setColor(255, 255, 0)
   love.graphics.line(min_of_game, 0, min_of_game, height)
   love.graphics.line(max_of_game, 0, max_of_game, height)
   love.graphics.line(width / 2, height * 2 / 5 , width / 2, height * 3 / 5)
   love.graphics.rectangle('line', 0, 0, width, height)
   love.graphics.circle('line', width / 2, height / 2, 10, 10)
end


function love.load()
   math.randomseed(os.time())

   love.keyboard.setKeyRepeat(true)

   width = love.graphics.getWidth()
   height = love.graphics.getHeight()

   setup()

   font = love.graphics.newFont(40)
   love.graphics.setFont(font)

   local joysticks = love.joystick.getJoysticks()
   player_2.joystick = joysticks[1]
end


function love.update(dt)
   goal:update(dt)

   ball:update(dt)

   if not ball.alive then
      -- too slow: end of point
      if ball.x < width / 2 then
	 -- player 1 court -> point to 2
	 point(player_2)
      else
	 -- player 2 court -> point to 1
	 point(player_1)
      end
      return restart()
   end

   player_1:update(dt)
   player_2:update(dt)

   if collision(ball, player_2) then
      bounce(ball, player_2, C.RANDOM_ANGLE)
   elseif collision(ball, player_1) then
      bounce(ball, player_1, C.RANDOM_ANGLE)
   elseif ball.x > ball.max_x then
      point(player_1)
      return restart()
   elseif ball.x < ball.min_x then
      point(player_2)
      return restart()
   end

   -- bounce up and down
   if ball.y < ball.min_y or ball.y > ball.max_y then
      -- no random angle added here
      ball.speed.y = -ball.speed.y
      ball.y = bound(ball.y, ball.min_y, ball.max_y)
   end
end


function love.draw()
   love.graphics.setBackgroundColor(0, 0, 200)

   goal:draw()

   if help_play then
      love.graphics.setColor(255, 218, 185)
      local dt = 1 -- 1 sec ahead
      love.graphics.line(ball.x, ball.y, ball.x + ball.speed.x * dt,  ball.y + ball.speed.y * dt)
   end

   -- court
   court_draw()

   -- players
   player_1:draw()
   player_2:draw()

   -- ball
   ball:draw()

   -- points
   love.graphics.setColor(123, 204, 40)
   love.graphics.print(player_1.points .. " : " .. player_2.points, 300, 300)
end


function love.keypressed(key)
   if not player_1:keypressed(key) then
      return
   elseif not player_2:keypressed(key) then
      return
   elseif key == "h" then
      help_play = not help_play
   end
end


function love.joystickpressed(joystick, button)
   if button == 17 then
      love.event.quit()
   end
end
