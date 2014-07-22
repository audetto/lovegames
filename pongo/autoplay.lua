local M = {}


local function intersect_x(dx, dy, x0, y0, x, min_y, max_y)
   local inc_x = (x - x0)
   if inc_x * dx > 0 then
      local y = inc_x * dy / dx + y0
      if y >= min_y and y <= max_y then
	 local t = {}
	 t.x = x
	 t.y = y
	 return t
      end
   end
end


local function intersect_y(dx, dy, x0, y0, y, min_x, max_x)
   local inc_y = y - y0
   if inc_y * dy > 0 then
      local x = inc_y * dx / dy + x0
      if x >= min_x and x <= max_x then
	 local t = {}
	 t.x = x
	 t.y = y
	 return t
      end
   end
end


function M.target(ball, player)
   local dx = ball.speed.x
   local dy = ball.speed.y

   local x0 = ball.x
   local y0 = ball.y

   local towards_us = dx * (x0 - player.x) < 0

   if towards_us then
      local targets = {}

      local counter = 0

      repeat
	 local done = true
	 local t

	 -- first let's check if it gets home
	 t = intersect_x(dx, dy, x0, y0, ball.min_x, ball.min_y, ball.max_y)
	 if not t then
	    t = intersect_x(dx, dy, x0, y0, ball.max_x, ball.min_y, ball.max_y)
	    if not t then 
	       t = intersect_y(dx, dy, x0, y0, ball.min_y, ball.min_x, ball.max_x)
	       if t then
		  done = false
	       else
		  t = intersect_y(dx, dy, x0, y0, ball.max_y, ball.min_x, ball.max_x)
		  if t then
		     done = false
		  end
	       end
	    end
	 end

	 if t then
	    targets[#targets + 1] = t
	    x0 = t.x
	    y0 = t.y
	 end
	 dy = -dy
	 counter = counter + 1
      until done or counter == 50

      return targets
   end
end

return M
