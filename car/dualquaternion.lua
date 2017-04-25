local quaternion = require("quaternion")

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

function mt.__pow(self, t)
   local omega, l, d2, m = self:split()

   local powOmega = omega * t
   local powD2 = d2 * t

   local coeff
   if omega == 0 then
      -- Taylor expansion would be
      -- coeff = t + (t - t ^ 3) / 6 * omega ^ 2
      coeff = t
   else
      coeff = math.sin(powOmega) / math.sin(omega)
   end

   local c = math.cos(powOmega)
   local s = math.sin(powOmega)

   local qr = quaternion.new(c, s * l[1], s * l[2], s * l[3])
   local qd = quaternion.new(-powD2 * s, powD2 * c * l[1] + s * m[1], powD2 * c * l[2] + s * m[2], powD2 * c * l[3] + s * m[3])

   return M.new(qr, qd)
end

local function conj(self)
   return M.new(self[1]:conj(), self[2]:conj())
end

local function norm(self)
   local a = self * self:conj()
   return math.sqrt(a[1][1])
end

local function split(self)
   local qr = self[1]
   local qd = self[2]

   local c = qr[1]
   local omega = math.acos(c)

   local s = math.sin(omega)
   local l = {qr[2] / s, qr[3] / s, qr[4] / s}

   local d2 = -qd[1] / s

   local m = {(qd[2] - d2 * c * l[1]) / s, (qd[3] - d2 * c * l[2]) / s, (qd[4] - d2 * c * l[3]) / s}

   return omega, l, d2, m
end

local function fromRT(r, t)
   local qr = r
   local qd = t * r * 0.5

   return M.new(qr, qd)
end

local function new(qr, qd)
   local d = {qr, qd}
   setmetatable(d, mt)

   d.norm = norm
   d.conj = conj
   d.split = split

   return d
end

M.new = new
M.fromRT = fromRT

return M
