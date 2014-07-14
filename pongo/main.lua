local Game = require("game")
local C = require("constants")

local game = Game.new()

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


function point(player)
   local goal = game.goal

   -- start goal effects
   goal:start()

   player.points = player.points + 1
end


function love.load()
   math.randomseed(os.time())

   love.keyboard.setKeyRepeat(true)

   game.width = love.graphics.getWidth()
   game.height = love.graphics.getHeight()

   game:setup()

   local font = love.graphics.newFont(40)
   love.graphics.setFont(font)

   local joysticks = love.joystick.getJoysticks()
   game.player_2.joystick = joysticks[1]
end


function love.update(dt)
   local goal = game.goal
   local ball = game.ball
   local player_1 = game.player_1
   local player_2 = game.player_2

   if goal:update(dt, game) then
      return
   elseif ball:update(dt, game) then
      return
   elseif player_1:update(dt, game) then
      return
   elseif player_2:update(dt, game) then
      return
   end
end


function love.draw()
   local goal = game.goal
   local ball = game.ball
   local player_1 = game.player_1
   local player_2 = game.player_2

   love.graphics.setBackgroundColor(0, 0, 200)

   goal:draw()

   -- court
   game:draw_court()

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
   local ball = game.ball
   local player_1 = game.player_1
   local player_2 = game.player_2

   if player_1:keypressed(key) then
      return
   elseif player_2:keypressed(key) then
      return
   elseif ball:keypressed(key) then
      return
   end
end


function love.joystickpressed(joystick, button)
   if button == 17 then
      love.event.quit()
   end
end
