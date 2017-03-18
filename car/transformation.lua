local vector = require("vector")
local matrix = require("matrix")

local M = {}

local function toString(self)
   return "Translation: " .. vector.toString(self.translation) .. "\nRotation: " .. matrix.toString(self.rotation)
end

local mt = { __tostring = toString }

local function translate(self, direction, coeff)
   if coeff == 0 then
      return
   end
   self.translation = vector.add(self.translation, self.translation, coeff, direction)
end

local function rotate(self, a, angle)
   if angle == 0 then
      return
   end
   local c = math.cos(angle)
   local s = math.sin(angle)
   local rot = matrix.new({
	 {c + a[1] * a[1] * (1 - c), a[1] * a[2] * (1 - c) - a[3] * s, a[1] * a[3] * (1 - c) + a[2] * s},
	 {a[2] * a[1] * (1 - c) + a[3] * s, c + a[2] * a[2] * (1 - c), a[2] * a[3] * (1 - c) - a[1] * s},
	 {a[3] * a[1] * (1 - c) - a[2] * s, a[3] * a[2] * (1 - c) + a[1] * s, c + a[3] * a[3] * (1 - c)}
   })

   -- premultiply to rotate around local axes
   local new = matrix.mulmm(self.work, rot, self.rotation)
   self.rotation, self.work = self.work, self.rotation
end

local function getY(self)
   return self.rotation[2]
end

local function new(point)
   local p = {}

   setmetatable(p, mt)

   p.translation = point
   p.rotation = matrix.new({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}})

   p.work = matrix.empty()
   p.getY = getY
   p.rotate = rotate
   p.translate = translate

   return p
end

M.x = vector.new({1, 0, 0})
M.y = vector.new({0, 1, 0})
M.z = vector.new({0, 0, 1})

M.new = new

return M
