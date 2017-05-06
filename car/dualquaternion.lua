local quaternion = require("quaternion")
local vector = require("vector")
local matrix = require("matrix")

local M = {}

local mt = {}

function mt.__tostring(self)
   local qr = tostring(self[1])
   local qd = tostring(self[2])

   return "R: " .. qr .. ", D: " .. qd
end

function mt.__unm(self)
   return M.new(-self[1], -self[2])
end

function mt.__add(self, rhs)
   return M.new(self[1] + rhs[1], self[2] + rhs[2])
end

function mt.__sub(self, rhs)
   return M.new(self[1] - rhs[1], self[2] - rhs[2])
end

function mt.__mul(self, rhs)
   if type(rhs) == "number" then
      return M.new(self[1] * rhs, self[2] * rhs)
   else
      return M.new(self[1] * rhs[1], self[1] * rhs[2] + self[2] * rhs[1])
   end
end

function mt.__div(self, rhs)
   return M.new(self[1] / rhs, self[2] / rhs)
end

function mt.__pow(self, t)
   -- inspired from
   -- https://svn.artisynth.org/svn/artisynth_core/trunk/src/maspack/matrix/DualQuaternion.java
   -- plus corrections and excess

   -- does work as well even if it is not a unit
   local alpha2, relativeExcess, omega, l, d2, m = self:split()

   local powOmega = omega * t
   local powD2 = d2 * t
   local powAlpha = alpha2 ^ (t / 2)

   local c = powAlpha * math.cos(powOmega)
   local s = powAlpha * math.sin(powOmega)

   local coeff = relativeExcess * t

   local qr = quaternion.new(c, s * l[1], s * l[2], s * l[3])
   local qd = quaternion.new(
	 -powD2 * s + qr[1] * coeff,
      powD2 * c * l[1] + s * m[1] + qr[2] * coeff,
      powD2 * c * l[2] + s * m[2] + qr[3] * coeff,
      powD2 * c * l[3] + s * m[3] + qr[4] * coeff)

   return M.new(qr, qd)
end

local function split(self)
   local qr = self[1]
   local qd = self[2]

   local alphaSin2 = qr[2] * qr[2] + qr[3] * qr[3] + qr[4] * qr[4]
   local excess = qr[1] * qd[1] + qr[2] * qd[2] + qr[3] * qd[3] + qr[4] * qd[4]
   local alphaCos = qr[1]
   local alpha2 = alphaCos * alphaCos + alphaSin2

   if alpha2 == 0 then
      -- it is a ZERO
      -- how do we handle it?
      return
   end

   local relativeExcess = excess / alpha2

   -- excess-normalised dual quaternion
   local qdn = {qd[1] - qr[1] * relativeExcess,
		qd[2] - qr[2] * relativeExcess,
		qd[3] - qr[3] * relativeExcess,
		qd[4] - qr[4] * relativeExcess}

   if alphaSin2 == 0 then
      local alphaD2Cos = math.sqrt(qdn[2] * qdn[2] + qdn[3] * qdn[3] + qdn[4] * qdn[4])
      local d2 = alphaD2Cos / alphaCos -- same sign as alphaCos

      local l
      if alphaD2Cos == 0 then
	 l = {1, 0, 0} -- l must have norm 1, arbitrary
      else
	 l = {qdn[2] / alphaD2Cos, qdn[3] / alphaD2Cos, qdn[4] / alphaD2Cos}
      end

      -- arbitrary m, s.t. dot(l, m) = 0
      -- alternative: {l[2] - l[3], l[3] - l[1], l[1] - l[2]}
      local m = {0, 0, 0}
      local omega = math.atan2(0, alphaCos)

      return alpha2, relativeExcess, omega, l, d2, m
   else

      local alphaSin = math.sqrt(alphaSin2)

      local omega = math.atan2(alphaSin, alphaCos) -- omega = theta / 2

      local l = {qr[2] / alphaSin, qr[3] / alphaSin, qr[4] / alphaSin}

      local d2 = -qdn[1] / alphaSin

      local coeff = alphaCos * qdn[1] / alphaSin2
      local m = {
	 qdn[2] / alphaSin + l[1] * coeff,
	 qdn[3] / alphaSin + l[2] * coeff,
	 qdn[4] / alphaSin + l[3] * coeff}

      return alpha2, relativeExcess, omega, l, d2, m
   end
end

local function conj(self)
   return M.new(self[1]:conj(), self[2]:conj())
end

local function conj3(self)
   return M.new(self[1]:conj(), -self[2]:conj())
end

local function norm(self)
   local a = self * self:conj()
   return math.sqrt(a[1][1])
end

local function equivalent(self)
   local Aa2 = self[1][1] ^ 2
   local Ax2 = self[1][2] ^ 2
   local Ay2 = self[1][3] ^ 2
   local Az2 = self[1][4] ^ 2

   local t1 = 2 * (-self[2][1] * self[1][2] + self[2][4] * self[1][3] - self[2][3] * self[1][4] + self[2][2] * self[1][1])
   local t2 = 2 * (-self[2][4] * self[1][2] - self[2][1] * self[1][3] + self[2][2] * self[1][4] + self[2][3] * self[1][1])
   local t3 = 2 * ( self[2][3] * self[1][2] - self[2][2] * self[1][3] - self[2][1] * self[1][4] + self[2][4] * self[1][1])

   local m = matrix.new({
	 {Ax2 - Ay2 - Az2 + Aa2, 2 * (self[1][3] * self[1][2] - self[1][1] * self[1][4]), 2 * (self[1][2] * self[1][4] + self[1][3] * self[1][1]), t1},
	 {2 * (self[1][2] * self[1][3] + self[1][4] * self[1][1]), -Ax2 + Ay2 - Az2 + Aa2, 2 * (-self[1][2] * self[1][1] + self[1][4] * self[1][3]), t2},
	 {2 * (self[1][2] * self[1][4] - self[1][3] * self[1][1]), 2 * (self[1][2] * self[1][1] + self[1][4] * self[1][3]), -Ax2 - Ay2 + Az2 + Aa2, t3},
	 {0, 0, 0, 1}
   })
   return m
end

local function transform_matrix(self, x)
   if self.matrix == nil then
      self.matrix = self:equivalent()
   end
   return self.matrix:transform(x)
end

local function transform_hamilton(self, x)
   if x[4] == 0 then
      return self[1]:transform(x)
   else
      local qr = quaternion.one
      local qd = quaternion.fromTranslation(x, 1)
      local d = M.new(qr, qd)

      local dres = self * d * self:conj3()

      local res = vector.new({dres[2][2], dres[2][3], dres[2][4], x[4]})
      return res
   end
end

local function fromRT(r, t)
   local qr = r or quaternion.one
   local qd = (t and (t * qr * 0.5)) or quaternion.zero

   return M.new(qr, qd)
end

local function new(qr, qd)
   local d = {qr or quaternion.one, qd or quaternion.zero}
   setmetatable(d, mt)

   d.norm = norm
   d.conj = conj
   d.conj3 = conj3
   d.split = split
   d.transform = transform_matrix
   d.equivalent = equivalent
   d.matrix = nil

   return d
end

M.new = new
M.fromRT = fromRT

return M
