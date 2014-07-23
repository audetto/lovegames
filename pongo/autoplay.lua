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
	 local pos = {x = x, y = y, vx = pos0.vx, vy = pos0.vy, t0 = hit_time}
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
	 local pos = {x = x, y = y, vx = pos0.vx, vy = pos0.vy, t0 = hit_time}
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

   local a = pos.vx ^ 2 + pos.vy ^ 2 - C.PADDLE_SPEED ^ 2
   local b = dx * pos.vx + dy * pos.vy
   local c = dx ^ 2 + dy ^ 2

   local disc = b ^ 2 - a * c
   if disc > 0 then
      local d = math.sqrt(disc)
      local t0 = (-b - d) / a
      local t1 = (-b + d) / a

      t0, t1 = math.min(t0, t1), math.max(t0, t1)

      local z1, z2 = intersection(t0, t1, 0, pos.t1 - pos.t0)

      if z1 and z2 then
	 local target = {}

	 local target_t = z1
	 target.t = target_t
	 target.x = pos.x + target_t * pos.vx
	 target.y = pos.y + target_t * pos.vy

	 return target
      end
   end
end


function M.target(ball, player)
   local pos0 = {x = ball.x, y = ball.y, vx = ball.speed.x, vy = ball.speed.y, t0 = 0}

   local towards_us = ball.speed.x * (player.x - pos0.x) > 0

   if towards_us then
      local positions = {}

      local counter = 0
      local playable = false

      repeat
	 local goal = false
	 local bounce = false

	 local pos

	 -- first let's check if it gets home
	 pos = intersect_x(pos0, player.center_x, ball.min_y, ball.max_y)
	 if pos then
	    -- it is on our side of the court
	    playable = true
	 else
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
	    -- start a new segment
	    pos0 = pos

	    if bounce then
	       pos0.vy = -pos0.vy
	    end

	    if playable and not goal then
	       positions[#positions + 1] = pos0
	    end
	 end

	 -- just to avoid nasty infinite loops
	 counter = counter + 1
      until goal or counter == 50

      for _, pos in ipairs(positions) do
	 local target = solve_segment(player, pos)
	 if target then
	    return target
	 end
      end
   end
end

return M
