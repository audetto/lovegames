local Player = require "player"

-- this is the top left
local player_1 = Player.new({})
local player_2 = Player.new({})

-- this is the centre
local ball = {}

-- radians
local random_angle = 0.1

-- autoplay
local auto_play = false
local help_play = false


function bounce(angle, wall, random_angle)
   local a = -angle + 2 * wall
   local extra = (math.random() - 0.5) * random_angle
   a = a + extra
   return a
end


function bound(value, min, max)
   return math.min(math.max(value, min), max)
end


-- the collision is only wrt the main side of the paddle
-- so we are checking intersection between a segment of a line and a circle
function collision(player)
   local m = math.tan(player.angle)
   local a = -m
   local b = 1
   local c = m * player.x - player.y

   local collision = false

   local dist_fromline = math.abs(a * ball.x + b * ball.y + c) / math.sqrt(a * a + b * b)
   if dist_fromline < ball.r then
      local dist_fromcentre = math.sqrt((player.x - ball.x) ^ 2 + (player.y - ball.y) ^ 2)
      if dist_fromcentre < player.height / 2 then
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

   local paddle_h = 100

   ball.r = 15
   ball.color = {204, 204, 0}
   ball.min_x = min_of_game + ball.r
   ball.max_x = max_of_game - ball.r
   ball.min_y = ball.r
   ball.max_y = height - ball.r

   -- player 1
   player_1.points = 0
   player_1.color = {255, 0, 0}

   player_1.x = min_of_game
   player_1.y = height / 2
   player_1.speed_x = 200
   player_1.speed_y = 500

   player_1.min_y = 0
   player_1.max_y = height
   player_1.min_x = min_of_game
   player_1.max_x = width / 2
   player_1.height = paddle_h
   player_1.width = 10

   player_1.angle = math.pi / 2

   player_1.keys = {}
   player_1.keys.up = "w"
   player_1.keys.down = "s"
   player_1.keys.left = "a"
   player_1.keys.right = "d"
   player_1.keys.clock = "x"
   player_1.keys.anti = "z"

   -- player 2
   player_2.points = 0
   player_2.color = {255, 255, 0}

   player_2.x = max_of_game
   player_2.y = height / 2
   player_2.speed_x = 200
   player_2.speed_y = 500
   player_2.min_y = 0
   player_2.max_y = height
   player_2.min_x = width / 2
   player_2.max_x = max_of_game
   player_2.height = paddle_h
   player_2.width = -10

   player_2.angle = math.pi / 2

   player_2.keys = {}
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
   ball.speed = 200

   ball.angle = (math.random() - 0.5) * math.pi / 2

   -- reset collision
   player_1.collision = false
   player_2.collision = false
   -- leave players where they are
end


function ball_draw(ball)
   love.graphics.setColor(ball.color)
   love.graphics.circle('fill', ball.x, ball.y, ball.r, 10)
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
   joystick = joysticks[1]
end


function love.update(dt)
   dx = math.cos(ball.angle) * ball.speed
   dy = math.sin(ball.angle) * ball.speed

   ball.x = ball.x + dx * dt
   ball.y = ball.y + dy * dt

   if auto_play then
      -- this line makes it plays automatically
      -- player_2.y = ball.y
      player_1.y = ball.y
   else
      player_1:update(dt)
   end

   player_2:update(dt)

   if collision(player_2) then
      ball.angle = bounce(ball.angle, player_2.angle, random_angle)
   elseif collision(player_1) then
      ball.angle = bounce(ball.angle, player_1.angle, random_angle)
   elseif ball.x > ball.max_x then
      player_1.points = player_1.points + 1
      restart()
   elseif ball.x < ball.min_x then
      player_2.points = player_2.points + 1
      restart()
   end

   -- bounce up and down
   if ball.y < ball.min_y or ball.y > ball.max_y then
      -- no random angle added here
      ball.angle = bounce(ball.angle, 0, 0)
      ball.y = bound(ball.y, ball.min_y, ball.max_y)
   end

end


function love.draw()
   love.graphics.setBackgroundColor(0, 0, 200)

   if help_play then
      love.graphics.setColor(255, 218, 185)
      love.graphics.line(ball.x, ball.y, ball.x + dx * 1, ball.y + dy * 1)
   end

   -- court
   court_draw()

   -- players
   player_1:draw()
   player_2:draw()

   -- ball
   ball_draw(ball)

   -- points
   love.graphics.setColor(123, 204, 40)
   love.graphics.print(player_1.points .. " : " .. player_2.points, 300, 300)
end


function love.keypressed(key)
   if not player_1:keypressed(key) then
      return
   elseif not player_2:keypressed(key) then
      return
   elseif key == "up" then
      ball.speed = ball.speed + 10
   elseif key == "down" then
      ball.speed = ball.speed - 10
   elseif key == "q" then
      auto_play = not auto_play
   elseif key == "h" then
      help_play = not help_play
   end
end


function love.joystickpressed(joystick, button)
   if button == 17 then
      love.event.quit()
   end
end
