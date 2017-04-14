local vector = require("vector")

local M = {}

local function toString(x)
   local s1 = tostring(x[1])
   local s2 = tostring(x[2])
   local s3 = tostring(x[3])
   return "{ " .. s1 .. ", " .. s2 .. ", " .. s3 .. " }"
end

local mt = {__tostring = toString}

local function mulmv(a, b)
   local res = vector.empty()
   res[1] = vector.dot(a[1], b)
   res[2] = vector.dot(a[2], b)
   res[3] = vector.dot(a[3], b)
   return res
end

local function dott(a, b, col)
   local res = a[1] * b[1][col] + a[2] * b[2][col] + a[3] * b[3][col]
   return res
end

local function mulmm(a, b)
   local res = M.empty()
   res[1][1] = dott(a[1], b, 1)
   res[1][2] = dott(a[1], b, 2)
   res[1][3] = dott(a[1], b, 3)
   res[2][1] = dott(a[2], b, 1)
   res[2][2] = dott(a[2], b, 2)
   res[2][3] = dott(a[2], b, 3)
   res[3][1] = dott(a[3], b, 1)
   res[3][2] = dott(a[3], b, 2)
   res[3][3] = dott(a[3], b, 3)
   return res
end

local function new(x)
   setmetatable(x, mt)

   x[1] = vector.new(x[1])
   x[2] = vector.new(x[2])
   x[3] = vector.new(x[3])

   return x
end

local function empty()
   local x = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
   return new(x)
end

local function diag(d)
   local x = {{d[1], 0, 0}, {0, d[2], 0}, {0, 0, d[3]}}
   return new(x)
end

local function t(self)
   return new({
	 {self[1][1], self[2][1], self[3][1]},
	 {self[1][2], self[2][2], self[3][2]},
	 {self[1][3], self[2][3], self[3][3]}
   })
end

local function rotation(a, angle)
   local c = math.cos(angle)
   local s = math.sin(angle)
   local rot = new({
	 {c + a[1] * a[1] * (1 - c), a[1] * a[2] * (1 - c) - a[3] * s, a[1] * a[3] * (1 - c) + a[2] * s},
	 {a[2] * a[1] * (1 - c) + a[3] * s, c + a[2] * a[2] * (1 - c), a[2] * a[3] * (1 - c) - a[1] * s},
	 {a[3] * a[1] * (1 - c) - a[2] * s, a[3] * a[2] * (1 - c) + a[1] * s, c + a[3] * a[3] * (1 - c)}
   })
   return rot
end

M.toString = toString
M.new = new
M.empty = empty
M.diag = diag
M.rotation = rotation
M.mulmv = mulmv
M.mulmm = mulmm
M.t = t

return M
