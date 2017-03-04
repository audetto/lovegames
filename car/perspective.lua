local vector = require("vector")

local M = {}

local function T(self, point)
   local ret = vector.sub(point, self.eye)
   return ret
end

local function R(self, point)
   local ret = {x = self.c1 * point.x - self.s1 * point.y, y = self.s1 * point.x + self.c1 * point.y, z = point.z}
   return ret
end

local function S(self, point)
   local ret = {x = point.x, y = self.c2 * point.y + self.s2 * point.z, z = -self.s2 * point.y + self.c2 * point.z}
   return ret
end

local function SRT(self, point)
   local t = self:T(point)
   local r = self:R(t)
   local s = self:S(r)
   return s
end

local function camera(self, eye, centre)
   self.eye = eye

   local dp = self:T(centre)
   local r1 = vector.norm(dp.x, dp.y, 0)
   local r2 = vector.norm(dp.x, dp.y, dp.z)

   self.s1 = dp.x / r1
   self.c1 = dp.y / r1

   local rdp = self:R(dp)

   self.c2 = rdp.y / r2
   self.s2 = rdp.z / r2
end

local function projection(self, point)
   local srt = self:SRT(point)
   local ret = {x = srt.x / srt.y, z = srt.z / srt.y}
   return ret, srt
end

local function line(self, a, b)
   local pa, ra = self:projection(a)
   local pb, rb = self:projection(b)

   if ra.y <= self.eps and rb.y <= self.eps then
      return
   end

   if ra.y <= self.eps then
      pa, ra, pb, rb = pb, rb, pa, ra
   end

   if rb.y <= self.eps then
      local weight_a = (self.eps - rb.y) / (ra.y - rb.y)

      local new_x = ra.x * weight_a  + rb.x * (1 - weight_a)
      local new_z = ra.z * weight_a  + rb.z * (1 - weight_a)

      -- this is basically an other projection
      pb.x = new_x / self.eps
      pb.z = new_z / self.eps
   end

   return pa, pb
end

local function new()
   local p = {}

   p.eps = 0.01

   p.T = T
   p.R = R
   p.S = S
   p.SRT = SRT
   p.camera = camera
   p.projection = projection
   p.line = line

   return p
end

M.new = new

return M
