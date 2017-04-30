local vector = require("vector")

local M = {}

local mt = {}

function mt.__tostring(self)
   return table.concat(self, ", ")
end

function mt.__unm(self)
   return M.new(-self[1], -self[2], -self[3], -self[4])
end

function mt.__add(self, rhs)
   return M.new(self[1] + rhs[1], self[2] + rhs[2], self[3] + rhs[3], self[4] + rhs[4])
end

function mt.__sub(self, rhs)
   return M.new(self[1] - rhs[1], self[2] - rhs[2], self[3] - rhs[3], self[4] - rhs[4])
end

function mt.__mul(self, rhs)
   if type(rhs) == "number" then
      return M.new(self[1] * rhs, self[2] * rhs, self[3] * rhs, self[4] * rhs)
   else
      return M.mul(self, rhs)
   end
end

function mt.__div(self, rhs)
   return M.new(self[1] / rhs, self[2] / rhs, self[3] / rhs, self[4] / rhs)
end

function mt.__pow(self, t)
   -- does work as well even if it is not a unit
   local alphaCos = self[1]
   local alphaSin2 = self[2] * self[2] + self[3] * self[3] + self[4] * self[4]

   local alphaSin = math.sqrt(alphaSin2)
   local omega = math.atan2(alphaSin, alphaCos) -- omega = theta / 2

   local alpha2 = alphaCos * alphaCos + alphaSin2
   local powOmega = omega * t
   local powAlpha = alpha2 ^ (t / 2)

   local l

   if alphaSin == 0 then
      -- arbitrary choice
      l = {1, 0, 0}
   else
      l = {self[2] / alphaSin, self[3] / alphaSin, self[4] / alphaSin}
   end

   local powAlphaCos = powAlpha * math.cos(powOmega)
   local powAlphaSin = powAlpha * math.sin(powOmega)
   return M.new(powAlphaCos, l[1] * powAlphaSin, l[2] * powAlphaSin, l[3] * powAlphaSin)

end

local function mul(self, rhs)
   local a = self[1] * rhs[1] - self[2] * rhs[2] - self[3] * rhs[3] - self[4] * rhs[4]
   local b = self[1] * rhs[2] + self[2] * rhs[1] + self[3] * rhs[4] - self[4] * rhs[3]
   local c = self[1] * rhs[3] - self[2] * rhs[4] + self[3] * rhs[1] + self[4] * rhs[2]
   local d = self[1] * rhs[4] + self[2] * rhs[3] - self[3] * rhs[2] + self[4] * rhs[1]

   return M.new(a, b, c, d)
end

local function conj(self)
   return M.new(self[1], -self[2], -self[3], -self[4])
end

local function norm(self)
   local a = self[1] * self[1] + self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
   return math.sqrt(a)
end

local function transform(self, x)
   local q = M.fromTranslation(x, 1)

   local qres = self * q * self:conj()

   local res = vector.new({qres[2], qres[3], qres[4], x[4]})
   return res
end

local function fromRotation(angle, axis)
   local omega = angle / 2
   local c = math.cos(omega)
   local s = math.sin(omega)

   return M.new(c, -s * axis[1], -s * axis[2], -s * axis[3])
end

local function fromTranslation(x, coeff)
   coeff = coeff or 1
   return M.new(0, x[1] * coeff, x[2] * coeff, x[3] * coeff)
end

local function new(a, b, c, d)
   local q = {a, b, c, d}
   setmetatable(q, mt)

   q.norm = norm
   q.conj = conj
   q.transform = transform

   return q
end

M.new = new
M.mul = mul
M.fromRotation = fromRotation
M.fromTranslation = fromTranslation
M.one = M.new(1, 0, 0, 0)
M.zero = M.new(0, 0, 0, 0)

return M
