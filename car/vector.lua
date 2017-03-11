local torch = require("torch")

local M = {}

local function toString(a)
   local n = a:nDimension()
   if n == 1 then
      local str = string.format("{ %.2f, %.2f, %.2f }", a[1], a[2], a[3])
      return str
   elseif n == 2 then
      local str = string.format("{ %s, %s, %s }", toString(a[1]), toString(a[2]), toString(a[3]))
      return str
   end
end

local function angle(a, b)
   local d = torch.dot(a, b)
   local na = torch.norm(a)
   local nb = torch.norm(b)

   local ac = d / (na * nb)
   return math.acos(ac)
end

M.angle = angle
M.toString = toString

return M
