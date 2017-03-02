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
   return ret
end

local function new()
   local p = {}
   p.T = T
   p.R = R
   p.S = S
   p.SRT = SRT
   p.camera = camera
   p.projection = projection
   return p
end

M.new = new

return M
