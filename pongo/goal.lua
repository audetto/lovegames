local C = require("constants")

local M = {}

local function goal_start(self)
   self.t = 0
   self.x = 0
end

local function goal_draw(self)
   if self.t then
      love.graphics.translate(self.x, self.x)
   end
end

local function goal_update(self, dt, game)
   if self.t then
      self.t = self.t + dt
      local t = self.t

      if t > C.GOAL_MAX_TIME then
	 self.t = nil
      else
	 local t_adj = C.GOAL_SPEED * t
	 self.x = C.GOAL_MAX_PIXELS * math.sin(t_adj) / t_adj
      end
   end
end

function M.new()
   local g = {}
   g.t = nil
   g.start = goal_start
   g.update = goal_update
   g.draw = goal_draw
   return g
end

return M
