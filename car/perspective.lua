local vector = require("vector")

local M = {}

local function setCamera(self, transformation)
   self.transformation = transformation
end

local function projection(self, point)
   local srt = self.transformation:transform(point)
   srt[1] = srt[1] * self.sign
   srt[2] = srt[2] * self.sign
   local ret = {srt[1] / srt[2], srt[3] / srt[2]}
   return { ret, srt }
end

local function limitProjection(res, eps, ahead, behind)
   local weight_a = (eps - behind[2]) / (ahead[2] - behind[2])

   local new_x = ahead[1] * weight_a  + behind[1] * (1 - weight_a)
   local new_y = eps
   local new_z = ahead[3] * weight_a  + behind[3] * (1 - weight_a)

   -- this is basically another projection
   res[1] = new_x / new_y
   res[2] = new_z / new_y
end

local function line(self, a, b)
   local pa, ra = a[1], a[2]
   local pb, rb = b[1], b[2]

   if ra[2] <= self.eps then
      if rb[2] <= self.eps then
	 return
      else
	 limitProjection(pa, self.eps, rb, ra)
	 return pa, pb, false, true
      end
   else
      if rb[2] <= self.eps then
	 limitProjection(pb, self.eps, ra, rb)
	 return pa, pb, true, false
      else
	 return pa, pb, true, true
      end
   end

end

local function new()
   local p = {}

   p.sign = 1
   p.eps = 0.01

   p.setCamera = setCamera
   p.projection = projection
   p.line = line

   return p
end

M.new = new

return M
