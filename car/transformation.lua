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
   self.translation = vector.add(self.translation, coeff, direction)
end

local function rotate(self, a, angle)
   if angle == 0 then
      return
   end

   local rot = matrix.rotation(a, angle)

   -- premultiply to rotate around local axes
   self.rotation = matrix.mulmm(rot, self.rotation)
end

local function getY(self)
   return self.rotation[2]
end

local function new(point)
   local p = {}

   setmetatable(p, mt)

   p.translation = point
   p.rotation = matrix.new({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}})

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
