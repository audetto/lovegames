local vector = require("vector")
local torch = require("torch")

local M = {}

local function T(self, point)
   local ret = torch.add(point, -1, self.eye)
   return ret
end

local function R(self, point, inv)
   inv = inv or 1
   local s1 = inv * self.s1
   local ret = torch.Tensor({self.c1 * point[1] - s1 * point[2], s1 * point[1] + self.c1 * point[2], point[3]})
   return ret
end

local function S(self, point, inv)
   inv = inv or 1
   local s2 = inv * self.s2
   local ret = torch.Tensor({point[1], self.c2 * point[2] + s2 * point[3], -s2 * point[2] + self.c2 * point[3]})
   return ret
end

local function SRT(self, point)
   local t = self:T(point)
   local r = self:R(t)
   local s = self:S(r)
   return s
end

local function rotation(self, point, inv)
   if not inv then
      local r = self:R(point)
      local s = self:S(r)
      return s
   else
      local s = self:S(point, inv)
      local r = self:R(s, inv)
      return r
   end
end

local function camera(self, eye, direction, sign)
   self.eye = eye

   local dp = direction
   local r1 = vector.norm(dp[1], dp[2], 0)
   local r2 = torch.norm(dp)

   self.s1 = dp[1] / r1 * sign
   self.c1 = dp[2] / r1 * sign

   local rdp = self:R(dp)

   self.c2 = rdp[2] / r2 * sign
   self.s2 = rdp[3] / r2 * sign
end

local function projection(self, point, relative)
   local srt
   if relative then
      -- it would be nice to remove the sign
      -- so that we have relative ahead and behind
      -- while it is always relative ahead now
      srt = point
   else
      srt = self:SRT(point)
   end
   local ret = torch.Tensor({srt[1] / srt[2], srt[3] / srt[2]})
   return ret, srt
end

local function line(self, a, b, relative)
   local pa, ra = self:projection(a, relative)
   local pb, rb = self:projection(b, relative)

   if ra[2] <= self.eps and rb[2] <= self.eps then
      return
   end

   if ra[2] <= self.eps then
      pa, ra, pb, rb = pb, rb, pa, ra
   end

   if rb[2] <= self.eps then
      local weight_a = (self.eps - rb[2]) / (ra[2] - rb[2])

      local new_x = ra[1] * weight_a  + rb[1] * (1 - weight_a)
      local new_z = ra[3] * weight_a  + rb[3] * (1 - weight_a)

      -- this is basically an other projection
      pb[1] = new_x / self.eps
      pb[2] = new_z / self.eps
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
   p.rotation = rotation
   p.camera = camera
   p.projection = projection
   p.line = line

   return p
end

M.new = new

return M
