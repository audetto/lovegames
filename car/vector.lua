local M = {}

local function toString(a)
   local str = string.format("{ %.2f, %.2f, %.2f, %.2f }", a[1], a[2], a[3], a[4])
   return str
end

local function dot(self, b)
   local res = self[1] * b[1] + self[2] * b[2] + self[3] * b[3] + self[4] * b[4]
   return res
end

local function dot3(self, b)
   local res = self[1] * b[1] + self[2] * b[2] + self[3] * b[3]
   return res
end

local function norm(self)
   local res = dot3(self, self)
   res = math.sqrt(res)
   return res
end

local function add(x, a, y)
   local res = M.empty()
   res[1] = x[1] + a * y[1]
   res[2] = x[2] + a * y[2]
   res[3] = x[3] + a * y[3]

   return res
end

local function cosangle(self, b)
   local d = dot3(self, b)
   local na = self:norm()
   local nb = b:norm()

   local ac = d / (na * nb)
   return ac
end

local function angle(self, b)
   local ac = cosangle(self, b)
   return math.acos(ac)
end

local function cross(a, b)
   local res = M.empty()
   res[1] = a[2] * b[3] - a[3] * b[2]
   res[2] = a[3] * b[1] - a[1] * b[3]
   res[3] = a[1] * b[2] - a[2] * b[1]

   -- this is super important as we will be applying the matrix transformation
   -- when drawing and transations should be ignored
   res[4] = 0

   return res
end

local mt = {__tostring = toString}

local function new(x)
   setmetatable(x, mt)
   x.norm = norm

   x[4] = x[4] or 1
   return x
end

local function empty()
   local x = {0, 0, 0, 1}
   return new(x)
end

M.toString = toString

M.angle = angle
M.cosangle = cosangle
M.norm = norm
M.add = add
M.new = new
M.empty = empty
M.dot = dot
M.cross = cross

return M
