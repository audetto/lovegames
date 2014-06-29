-- this is the top left
local paddle_h = 100

local paddle_1 = {}
local paddle_2 = {}

-- this is the centre
local ball_r = 15

-- radians
local random_angle = 0.1

-- autoplay
local auto_play = false
local help_play = false

local points_1 = 0
local points_2 = 0


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
function collision(paddle)
   local m = math.tan(paddle.angle)
   local a = -m
   local b = 1
   local c = m * paddle.x - paddle.y

   local collision = false

   local dist_fromline = math.abs(a * ball_x + b * ball_y + c) / math.sqrt(a * a + b * b)
   if dist_fromline < ball_r then
      local dist_fromcentre = math.sqrt((paddle.x - ball_x) ^ 2 + (paddle.y - ball_y) ^ 2)
      if dist_fromcentre < paddle_h / 2 then
	 collision = true
      end
   end

   -- after a collision we do not return an other collision
   -- until after a non collision has happened
   local old_collision = paddle.collision
   paddle.collision = collision

   return (not old_collision) and collision
end


function setup()
   -- 100 pixels are the "goal" zone on each side
   min_of_game = 100
   max_of_game = width - min_of_game

   paddle_1.x = min_of_game
   paddle_1.y = height / 2
   paddle_1.speed_x = 200
   paddle_1.speed_y = 500

   paddle_1.coeff_x = 0
   paddle_1.coeff_y = 0
   paddle_1.angle = math.pi / 2

   paddle_2.x = max_of_game
   paddle_2.y = height / 2
   paddle_2.speed_x = 200
   paddle_2.speed_y = 500

   paddle_2.coeff_x = 0
   paddle_2.coeff_y = 0
   paddle_2.angle = math.pi / 2

   scene_angle = 0

   restart()
end


function restart()
   -- ball in the centre
   ball_x = (min_of_game + max_of_game) / 2
   ball_y = height / 2

   -- points per second
   ball_speed = 200

   ball_angle = (math.random() - 0.5) * math.pi / 2

   paddle_1.collision = false
   paddle_2.collision = false
end


function love.load()
   math.randomseed(os.time())

   width = love.graphics.getWidth()
   height = love.graphics.getHeight()

   setup()

   love.keyboard.setKeyRepeat(true)

   ball_min_x = min_of_game + ball_r
   ball_max_x = max_of_game - ball_r
   ball_min_y = ball_r
   ball_max_y = height - ball_r

   paddle_min_y = 0
   paddle_max_y = height

   font = love.graphics.newFont(40)
   love.graphics.setFont(font)

   local joysticks = love.joystick.getJoysticks()
   joystick = joysticks[1]
end


function love.update(dt)
   dx = math.cos(ball_angle) * ball_speed
   dy = math.sin(ball_angle) * ball_speed

   ball_x = ball_x + dx * dt
   ball_y = ball_y + dy * dt

   if auto_play then
      -- this line makes it plays automatically
      -- paddle_2.y = ball_y
      paddle_1.y = ball_y
   else
      paddle_1.x = paddle_1.x + paddle_1.coeff_x * paddle_1.speed_x * dt
      paddle_1.y = paddle_1.y + paddle_1.coeff_y * paddle_1.speed_y * dt
      paddle_1.x = math.min(paddle_1.x, width / 2)
      paddle_1.x = bound(paddle_1.x, min_of_game, width / 2)
      paddle_1.y = bound(paddle_1.y, paddle_min_y, paddle_max_y)
   end

   paddle_2.coeff_x = joystick:getAxis(1)
   paddle_2.coeff_y = joystick:getAxis(2)
   paddle_2.angle = (joystick:getAxis(3) * 0.9 + 1) * math.pi / 2

   paddle_2.x = paddle_2.x + paddle_2.coeff_x * paddle_2.speed_x * dt
   paddle_2.y = paddle_2.y + paddle_2.coeff_y * paddle_2.speed_y * dt
   paddle_2.x = bound(paddle_2.x, width / 2, max_of_game)
   paddle_2.y = bound(paddle_2.y, paddle_min_y, paddle_max_y)

   if collision(paddle_2) then
      ball_angle = bounce(ball_angle, paddle_2.angle, random_angle)
   elseif collision(paddle_1) then
      ball_angle = bounce(ball_angle, paddle_1.angle, random_angle)
   elseif ball_x > ball_max_x then
      points_1 = points_1 + 1
      restart()
   elseif ball_x < ball_min_x then
      points_2 = points_2 + 1
      restart()
   end

   if ball_y < ball_min_y or ball_y > ball_max_y then
      -- no random angle added here
      ball_angle = bounce(ball_angle, 0, 0)
      ball_y = bound(ball_y, ball_min_y, ball_max_y)
   end

end


function love.draw()
   -- rotate around the center of the screen by angle radians

   love.graphics.translate(width / 2, height / 2)
   love.graphics.rotate(scene_angle)
   love.graphics.translate(-width / 2, -height / 2)

   love.graphics.setBackgroundColor(0, 0, 200)

   if help_play then
      love.graphics.setColor(255, 218, 185)
      love.graphics.line(ball_x, ball_y, ball_x + dx * 1, ball_y + dy * 1)
   end

   -- court lines

   love.graphics.setColor(255, 255, 0)
   love.graphics.line(min_of_game, 0, min_of_game, height)
   love.graphics.line(max_of_game, 0, max_of_game, height)
   love.graphics.line(width / 2, height * 2 / 5 , width / 2, height * 3 / 5)
   love.graphics.rectangle('line', 0, 0, width, height)
   love.graphics.circle('line', width / 2, height / 2, 10, 10)

   -- paddles

   love.graphics.setColor(255, 0, 0)
   love.graphics.push()
   love.graphics.translate(paddle_2.x, paddle_2.y)
   love.graphics.rotate(paddle_2.angle)
   love.graphics.rectangle('fill', -paddle_h / 2, 0, paddle_h, -10)
   love.graphics.pop()

   love.graphics.setColor(255, 255, 0)
   love.graphics.push()
   love.graphics.translate(paddle_1.x, paddle_1.y)
   love.graphics.rotate(paddle_1.angle)
   love.graphics.rectangle('fill', -paddle_h / 2, 0, paddle_h, 10)
   love.graphics.pop()

   -- ball

   love.graphics.setColor(204, 204, 0)
   love.graphics.circle('fill', ball_x, ball_y, ball_r, 10)

   love.graphics.setColor(123, 204, 40)
   love.graphics.print(points_1 .. " : " .. points_2, 300, 300)
end


function love.keypressed(key)
   if key == "e" then
      paddle_1.coeff_y = -1
   elseif key == "d" then
      paddle_1.coeff_y = 1
   elseif key =="k" then
      paddle_1.angle = paddle_1.angle + 0.1
   elseif key =="l" then
      paddle_1.angle = paddle_1.angle - 0.1

   elseif key == "up" then
      ball_speed = ball_speed + 10
   elseif key == "down" then
      ball_speed = ball_speed - 10
   elseif key == "q" then
      scene_angle = scene_angle + 0.1
   elseif key == "w" then
      scene_angle = scene_angle - 0.1
   elseif key == "a" then
      auto_play = not auto_play
   elseif key == "h" then
      help_play = not help_play
   end
end


function love.keyreleased(key)
   if key == "e" then
      paddle_1.coeff_y = 0
   elseif key == "d" then
      paddle_1.coeff_y = 0
   end
end


function love.joystickpressed(joystick, button)
   if button == 17 then
      love.event.quit()
   end
end
