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

   player.target = nil
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

   game:setup()
end


function love.update(dt)
   game:update(dt)
end


function love.draw()
   game:draw()
end


function love.keypressed(key)
   game:keypressed(key)
end


function love.joystickpressed(joystick, button)
   if button == 17 then
      love.event.quit()
   end
end

-- custom events

-- player is a string due to a limitation in love2d framework
-- where we cannot pass tables as events
function love.handlers.bounce(player)
   game:bounce(game.ball, game[player])
end

function love.handlers.newball()
   game:newball(game.ball)
end
