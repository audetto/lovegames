local C = require("constants")

local M = {}

-- apply deceleration
local function apply_deceleration(t, ball, deceleration)
   local speed = ball.speed.abs
   local speed2 = speed * speed
   local disc = speed2 - 2 * deceleration * speed * t
   -- if disc < 0, then the ball will never get there
   -- as it will stop sooner due to deceleration

   if disc >= 0 then
      local adjusted_t = (speed - math.sqrt(disc)) / deceleration
      return adjusted_t
   end
end


-- home target
local function home_target(player, track)
   -- ball is going towards the other player
   -- we just go to some rest position in the middle of our court
   -- 10% away from the goal line

   -- or when we do not know where to go
   local x = player.home_x + (player.center_x - player.home_x) * 0.1
   -- half in the y direction
   local target = {x = x, y = track.y, track = track}
   return target
end


-- maybe we should merge the 2 functions below
local function intersect_x(pos0, x, min_y, max_y)
   local inc_x = x - pos0.x

   -- first check intersection happens in the future
   local dt = inc_x / pos0.vx

   if dt > 0 then
      local y = inc_x * pos0.vy / pos0.vx + pos0.y
      if y >= min_y and y <= max_y then
	 local hit_time = pos0.t0 + dt
	 local pos = {x = x, y = y, t0 = hit_time, vx = pos0.vx, vy = pos0.vy, playable = pos0.playable}
	 -- this is the end of the previous segment
	 pos0.t1 = hit_time
	 return pos
      end
   end
end


local function intersect_y(pos0, y, min_x, max_x)
   local inc_y = y - pos0.y

   -- first check intersection happens in the future
   local dt = inc_y / pos0.vy

   if dt > 0 then
      local x = inc_y * pos0.vx / pos0.vy + pos0.x
      if x >= min_x and x <= max_x then
	 local hit_time = pos0.t0 + dt
	 local pos = {x = x, y = y, t0 = hit_time, vx = pos0.vx, vy = pos0.vy, playable = pos0.playable}
	 -- this is the end of the previous segment
	 pos0.t1 = hit_time
	 return pos
      end
   end
end


local function solve_segment(player, pos, ball)
   local dx = pos.x - player.x
   local dy = pos.y - player.y

   local n = C.PADDLE_SPEED ^ 2
   local a = pos.vx ^ 2 + pos.vy ^ 2 - n
   local b = dx * pos.vx + dy * pos.vy - n * pos.t0
   local c = dx ^ 2 + dy ^ 2 - n * pos.t0 ^ 2

   local disc = b ^ 2 - a * c
   if disc > 0 then
      local d = math.sqrt(disc)
      local t0 = (-b - d) / a
      local t1 = (-b + d) / a
      -- according to the sing of a, t0 is >< t1

      -- all relative to the begin of the segment
      local max_t = pos.t1 - pos.t0

      -- we want the minimum t, that is feasible and inside the segment (i.e. [0, max_t])

      local target_t
      if a > 0 then
	 -- solutions inside [t0, t1]
	 if t1 < 0 or t0 > max_t then
	    return nil
	 end
	 target_t = math.max(0, t0)
      else
	 -- solutions outside [t1, t0]
	 if t1 >= 0 then
	    target_t = 0
	 elseif t0 <= 0 then
	    target_t = 0
	 elseif t0 <= max_t then
	    target_t = t0
	 else
	    return nil
	 end
      end

      -- rebase the target time to be absolute
      local absolute_t = target_t + pos.t0

      -- take into account ball deceleration
      -- to be exact we should take this into account while solving
      -- but it gets complicated and we only readjust
      -- the hit point time
      local adjusted_t = apply_deceleration(absolute_t, ball, C.BALL_DECELERATION)

      local target
      if adjusted_t then
	 target = {}

	 -- calculate the ball position at the target time
	 target.x = pos.x + target_t * pos.vx
	 target.y = pos.y + target_t * pos.vy

	 target.t = adjusted_t
      else
	 -- ball will stop sooner
	 -- just go back home
	 target = home_target(player, {y = (player.min_y + player.max_y) / 2})
      end

      return target
   end
end


-- called after the ball get a new external direction
-- either we hit, opponent hits or kick off
function M.bounce(player, ball)
   -- check if the ball is going towards our goal line
   local towards_us = ball.speed.x * (player.home_x - ball.x) > 0

   if towards_us then
      local pos0 = {x = ball.x, y = ball.y, vx = ball.speed.x, vy = ball.speed.y, t0 = 0}

      -- if already playable
      pos0.playable = (player.center_x - ball.x) * (player.center_x - player.home_x) >= 0
      local pos

      local counter = 0
      repeat
	 local goal = false
	 local bounce = false

	 pos = nil
	 -- first let's check if it gets on our side of court
	 -- no need if it is already playable
	 if not pos0.playable then
	    pos = intersect_x(pos0, player.center_x, ball.min_y, ball.max_y)
	    if pos then
	       -- it is on our side of the court
	       pos.playable = true
	    end
	 end
	 if not pos then
	    pos = intersect_x(pos0, player.home_x, ball.min_y, ball.max_y)
	    if pos then
	       -- goal, this is the last segment
	       goal = true
	    else
	       -- these 2 are intersection with walls
	       pos = intersect_y(pos0, ball.min_y, ball.min_x, ball.max_x)
	       if not pos then
		  pos = intersect_y(pos0, ball.max_y, ball.min_x, ball.max_x)
		  if not pos then
		     print("so what?")
		  end
	       end
	       -- if we get here we have bounced on the walls
	       bounce = pos -- this is used as boolean
	    end
	 end

	 if pos then
	    -- we've just finished a segment
	    -- try to solve the previous one, if it was playable!
	    if pos0.playable then
	       local target = solve_segment(player, pos0, ball)
	       if target then
		  -- if there is a solution, just return it
		  -- plus we add some randomness on the angle
		  local half_y = (player.min_y + player.max_y) / 2
		  local coeff = target.y > half_y and -1 or 1
		  target.angle = coeff * math.random() * math.pi / 8 + math.pi / 2

		  return target
	       end
	    end

	    if bounce then
	       pos.vy = -pos.vy
	    end

	    -- start a new segment
	    pos0 = pos
	 end

	 -- just to avoid nasty infinite loops
	 counter = counter + 1
      until goal or counter == 50

      -- we failed to solve all segments
      -- return the last position known of the ball
      -- most likely a goal
      return pos
   else
      local target = home_target(player, ball)
      return target
   end
end


-- called on each update
-- e.g. if we simply want to track the ball
function M.update(player, ball, target)
   if target and target.track then
      target.y = target.track.y
   end
   return target
end


return M
