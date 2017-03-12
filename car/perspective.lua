local vector = require("vector")
local matrix = require("matrix")

local M = {}

local function camera(self, eye, direction, sign)
   self.eye = eye
   self.rotation = direction.axes
   self.sign = sign
end

local function projection(self, res, point, relative)
   local srt
   if relative then
      -- it would be nice to remove the sign
      -- so that we have relative ahead and behind
      -- while it is always relative ahead now
      srt = point
   else
      srt = vector.add(self.work1, point, -1, self.eye)
      srt = matrix.mulmv(res, self.rotation, srt)
      srt[1] = srt[1] * self.sign
      srt[2] = srt[2] * self.sign
   end
   local ret = {srt[1] / srt[2], srt[3] / srt[2]}
   return ret, srt
end

local function line(self, a, b, relative)
   local pa, ra = self:projection(self.work2, a, relative)
   local pb, rb = self:projection(self.work3, b, relative)

   if ra[2] <= self.eps and rb[2] <= self.eps then
      return
   end

   if ra[2] <= self.eps then
      pa, ra, pb, rb = pb, rb, pa, ra
   end

   if rb[2] <= self.eps then
      local weight_a = (self.eps - rb[2]) / (ra[2] - rb[2])

      local new_x = ra[1] * weight_a  + rb[1] * (1 - weight_a)
      local new_y = self.eps
      local new_z = ra[3] * weight_a  + rb[3] * (1 - weight_a)

      -- this is basically an other projection
      pb[1] = new_x / new_y
      pb[2] = new_z / new_y
   end

   return pa, pb
end

local function new()
   local p = {}

   p.work1 = vector.empty()
   p.work2 = vector.empty()
   p.work3 = vector.empty()

   p.eps = 0.01

   p.camera = camera
   p.projection = projection
   p.line = line

   return p
end

M.new = new

return M
