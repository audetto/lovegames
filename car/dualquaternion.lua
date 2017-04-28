local quaternion = require("quaternion")
local vector = require("vector")

local M = {}

local mt = {}

function mt.__tostring(self)
   local qr = tostring(self[1])
   local qd = tostring(self[2])

   return "R: " .. qr .. ", D: " .. qd
end

function mt.__add(self, rhs)
   return M.new(self[1] + rhs[1], self[2] + rhs[2])
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

-- pow does not work for
-- p1 = d.new(q.one * 9, -q.one * 8)
-- p2 = d.new(q.one * 9, -q.one * 8)
-- p2[1][2] = 0.1

function mt.__pow(self, t)
   local omega, l, d2, m, alpha2 = self:split()

   if omega == nil then
      local qr = self[1] ^ t
      local qd = self[2] * t

      return M.new(qr, qd)
   else
      local powOmega = omega * t
      local powD2 = d2 * t
      local powAlpha = alpha2 ^ (t / 2)

      local c = powAlpha * math.cos(powOmega)
      local s = powAlpha * math.sin(powOmega)

      local qr = quaternion.new(c, s * l[1], s * l[2], s * l[3])
      local qd = quaternion.new(-powD2 * s, powD2 * c * l[1] + s * m[1], powD2 * c * l[2] + s * m[2], powD2 * c * l[3] + s * m[3])

      return M.new(qr, qd)
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

local function split(self)
   local qr = self[1]
   local qd = self[2]

   local alphaSin2 = qr[2] * qr[2] + qr[3] * qr[3] + qr[4] * qr[4]

   if alphaSin2 == 0 then
      return
   end

   local alphaCos = qr[1]
   local alpha2 = alphaCos * alphaCos + alphaSin2

   local alphaSin = math.sqrt(alphaSin2)

   local omega = math.atan2(alphaSin, alphaCos) -- omega = theta / 2

   local l = {qr[2] / alphaSin, qr[3] / alphaSin, qr[4] / alphaSin}

   local d2 = -qd[1] / alphaSin

   local coeff = alphaCos * qd[1] / alphaSin2
   local m = {qd[2] / alphaSin + l[1] * coeff,
	      qd[3] / alphaSin + l[2] * coeff,
	      qd[4] / alphaSin + l[3] * coeff}

   return omega, l, d2, m, alpha2
end

local function transform(self, x)
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
   d.transform = transform

   return d
end

M.new = new
M.fromRT = fromRT

return M
