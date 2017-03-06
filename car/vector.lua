local torch = require("torch")

local M = {}

local function toString(a, decimal)
   local str = string.format("{ x = %8.2f, %8.2f, z = %8.2f }", a[1], a[2], a[3])
   return str
end

local function norm(a, b, c)
   local ret = math.sqrt(a * a + b * b + c * c)
   return ret
end

local function angle(a, b)
   local d = torch.dot(a, b)
   local na = torch.norm(a)
   local nb = torch.norm(b)

   local ac = d / (na * nb)
   return math.acos(ac)
end

local function rotate(a, angle_x, angle_y, angle_z)
   local ret = a

   local c_z = math.cos(angle_z)
   local s_z = math.sin(angle_z)

   ret = torch.Tensor({c_z * ret[1] - s_z * ret[2], s_z * ret[1] + c_z * ret[2], ret[3]})

   local c_x = math.cos(angle_x)
   local s_x = math.sin(angle_x)

   ret = torch.Tensor({ret[1], c_x * ret[2] - s_x * ret[3], s_x * ret[2] + c_x * ret[3]})

   return ret
end

M.norm = norm
M.angle = angle
M.toString = toString
M.rotate = rotate
M.round = round

return M
