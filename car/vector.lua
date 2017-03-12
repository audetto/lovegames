local M = {}

local function toString(a)
   local str = string.format("{ %.2f, %.2f, %.2f }", a[1], a[2], a[3])
   return str
end

local function dot(self, b)
   local res = self[1] * b[1] + self[2] * b[2] + self[3] * b[3]
   return res
end

local function norm(self)
   local res = dot(self, self)
   res = math.sqrt(res)
   return res
end

local function add(res, x, a, y)
   res[1] = x[1] + a * y[1]
   res[2] = x[2] + a * y[2]
   res[3] = x[3] + a * y[3]
   return res
end

local function angle(self, b)
   local d = dot(self, b)
   local na = norm(self)
   local nb = norm(b)

   local ac = d / (na * nb)
   return math.acos(ac)
end

local mt = {__tostring = toString}

local function new(x)
   setmetatable(x, mt)
   x.norm = norm
   x.dot = dot
   x.angle = angle
   return x
end

local function empty()
   local x = {0, 0, 0}
   return new(x)
end

local function clone(x)
   local y = {x[1], x[2], x[3]}
   return new(y)
end

M.toString = toString
M.angle = angle
M.norm = norm
M.add = add
M.new = new
M.empty = empty
M.dot = dot
M.clone = clone

return M
