local M = {}

local function toString(a, decimal)
   local str = string.format("{ x = %.2f, y = %.2f, x = %.2f }", a.x, a.y, a.x)
   return str
end

local function add(a, b)
   local ret = {x = a.x + b.x, y = a.y + b.y, z = a.z + b.z}
   return ret
end

local function axpy(scale, a, b)
   local ret = {x = scale * a.x + b.x, y = scale * a.y + b.y, z = scale * a.z + b.z}
   return ret
end

local function sub(a, b)
   local ret = {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z}
   return ret
end

local function norm(a, b, c)
   local ret = math.sqrt(a * a + b * b + c * c)
   return ret
end

local function rotate(a, angle_x, angle_y, angle_z)
   local ret = a

   local c_z = math.cos(angle_z)
   local s_z = math.sin(angle_z)

   ret = {x = c_z * ret.x - s_z * ret.y, y = s_z * ret.x + c_z * ret.y, z = ret.z}

   local c_x = math.cos(angle_x)
   local s_x = math.sin(angle_x)

   ret = {x = ret.x, y = c_x * ret.y - s_x * ret.z, z = s_x * ret.y + c_x * ret.z}

   return ret
end

M.add = add
M.sub = sub
M.norm = norm
M.axpy = axpy
M.toString = toString
M.rotate = rotate
M.round = round

return M
