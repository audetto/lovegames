local C = require("constants")

local M = {}

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


-- intersection of [x1, x2] and [y1, y2]
local function intersection(x1, x2, y1, y2)
   local z1 = math.max(x1, y1)
   local z2 = math.min(x2, y2)

   if z2 >= z1 then
      return z1, z2
   end
end


local function solve_segment(player, pos)
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

      local target = {}

      target.t = target_t
      -- calculate the ball position at the target time
      target.x = pos.x + target_t * pos.vx
      target.y = pos.y + target_t * pos.vy

      return target
   end
end


function M.target(ball, player)
   local towards_us = ball.speed.x * (player.x - ball.x) > 0

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
	       local target = solve_segment(player, pos0)
	       if target then
		  -- if there is a solution, just return it
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
   end
end

return M
