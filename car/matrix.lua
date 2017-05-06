local vector = require("vector")

local M = {}

local function toString(x)
   local s1 = tostring(x[1])
   local s2 = tostring(x[2])
   local s3 = tostring(x[3])
   local s4 = tostring(x[4])
   return "{ " .. s1 .. ", " .. s2 .. ", " .. s3 .. ", " .. s4 .. " }"
end

local mt = {__tostring = toString}

local function mulmv(a, b)
   local res = vector.empty()

   res[1] = vector.dot(a[1], b)
   res[2] = vector.dot(a[2], b)
   res[3] = vector.dot(a[3], b)
   res[4] = vector.dot(a[4], b)
   return res
end

local function dott(a, b, col)
   local res = a[1] * b[1][col] + a[2] * b[2][col] + a[3] * b[3][col] + a[4] * b[4][col]
   return res
end

local function mulmm(a, b)
   local res = M.empty()

   res[1][1] = dott(a[1], b, 1)
   res[1][2] = dott(a[1], b, 2)
   res[1][3] = dott(a[1], b, 3)
   res[1][4] = dott(a[1], b, 4)

   res[2][1] = dott(a[2], b, 1)
   res[2][2] = dott(a[2], b, 2)
   res[2][3] = dott(a[2], b, 3)
   res[2][4] = dott(a[2], b, 4)

   res[3][1] = dott(a[3], b, 1)
   res[3][2] = dott(a[3], b, 2)
   res[3][3] = dott(a[3], b, 3)
   res[3][4] = dott(a[3], b, 4)

   res[4][1] = dott(a[4], b, 1)
   res[4][2] = dott(a[4], b, 2)
   res[4][3] = dott(a[4], b, 3)
   res[4][4] = dott(a[4], b, 4)

   return res
end

local function column(self, i)
   local col = vector.new({self[1][i], self[2][i], self[3][i], self[4][i]})
   return col
end

local function empty()
   local x = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 1}}
   return M.new(x)
end

local function diag(d)
   local x = {{d[1], 0, 0, 0}, {0, d[2], 0, 0}, {0, 0, d[3], 0}, {0, 0, 0, 1}}
   return M.new(x)
end

local function id()
   local x = {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}
   return M.new(x)
end

local function inverse(self)
   -- only correct if this is a real ROTATION
   -- i.e. not scaling
   local t = M.new({
	 {self[1][1], self[2][1], self[3][1], 0},
	 {self[1][2], self[2][2], self[3][2], 0},
	 {self[1][3], self[2][3], self[3][3], 0},
	 {0,          0,          0,          1}
   })
   local p = self:column(4)
   local d = mulmv(t, p)

   t[1][4] = -d[1]
   t[2][4] = -d[2]
   t[3][4] = -d[3]
   t[4][4] = 1

   return t
end

local function rotation(a, angle)
   local c = math.cos(angle)
   local s = math.sin(angle)
   local rot = M.new({
	 {c + a[1] * a[1] * (1 - c), a[1] * a[2] * (1 - c) - a[3] * s, a[1] * a[3] * (1 - c) + a[2] * s, 0},
	 {a[2] * a[1] * (1 - c) + a[3] * s, c + a[2] * a[2] * (1 - c), a[2] * a[3] * (1 - c) - a[1] * s, 0},
	 {a[3] * a[1] * (1 - c) - a[2] * s, a[3] * a[2] * (1 - c) + a[1] * s, c + a[3] * a[3] * (1 - c), 0},
	 {0, 0, 0, 1}
   })
   return rot
end

local function translation(a, coeff)
   local trans = M.new({
	 {1, 0, 0, coeff * a[1]},
	 {0, 1, 0, coeff * a[2]},
	 {0, 0, 1, coeff * a[3]},
	 {0, 0, 0, 1}
   })
   return trans
end

local function new(x)
   setmetatable(x, mt)

   x[1] = vector.new(x[1])
   x[2] = vector.new(x[2])
   x[3] = vector.new(x[3])
   x[4] = vector.new(x[4])

   x.column = column
   x.inverse = inverse
   x.transform = mulmv

   return x
end

M.toString = toString
M.new = new
M.empty = empty
M.diag = diag
M.id = id
M.rotation = rotation
M.translation = translation
M.mulmv = mulmv
M.mulmm = mulmm

return M
