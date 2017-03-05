local M = {}

local function toString(a, decimal)
   local str = string.format("{ x = %8.2f, y = %8.2f, z = %8.2f }", a.x, a.y, a.z)
   return str
end

local function add(a, b)
   local ret = {x = a.x + b.x, y = a.y + b.y, z = a.z + b.z}
   return ret
end

-- result = scale * a + b
local function axpy(scale, a, b)
   local ret = {x = scale * a.x + b.x, y = scale * a.y + b.y, z = scale * a.z + b.z}
   return ret
end

local function sub(a, b)
   local ret = {x = a.x - b.x, y = a.y - b.y, z = a.z - b.z}
   return ret
end

local function mul(scale, a)
   local ret = {x = scale * a.x, y = scale * a.y, z = scale * a.z}
   return ret
end

local function norm(a, b, c)
   local ret = math.sqrt(a * a + b * b + c * c)
   return ret
end

local function dot(a, b)
   local ret = a.x * b.x + a.y * b.y + a.z * b.z
   return ret
end

local function angle(a, b)
   local d = dot(a, b)
   local na = norm(a.x, a.y, a.z)
   local nb = norm(b.x, b.y, b.z)

   local ac = d / (na * nb)
   return math.acos(ac)
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
M.mul = mul
M.norm = norm
M.axpy = axpy
M.dot = dot
M.angle = angle
M.toString = toString
M.rotate = rotate
M.round = round

return M
