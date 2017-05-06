local vector = require("vector")
local matrix = require("matrix")

local M = {}

local function toString(self)
   return "Matrix: " .. tostring(self.rotation)
end

local mt = { __tostring = toString }

local function translate(self, direction, coeff)
   if coeff == 0 then
      return
   end

   local rot = matrix.translation(direction, coeff)
   self:internal(rot)
end

local function rotate(self, a, angle)
   if angle == 0 then
      return
   end

   local rot = matrix.rotation(a, angle)
   self:internal(rot)
end

local function internal(self, m)
   -- postmultiply to rotate around local axes
   self.rotation = matrix.mulmm(self.rotation, m)
end

local function generic(self, t)
   self:internal(t.rotation)
end

local function getY(self)
   return self.rotation:column(2)
end

local function getPos(self)
   return self.rotation:column(4)
end

local function transform(self, x)
   return self.rotation:transform(x)
end

local function inverse(self)
   local rot = self.rotation:inverse()
   return M.new(rot)
end

local function clone(self)
   return M.new(self.rotation)
end

local function new(rot)
   local p = {}

   setmetatable(p, mt)

   p.rotation = rot or matrix.id()

   p.getY = getY
   p.getPos = getPos
   p.rotate = rotate
   p.translate = translate
   p.generic = generic
   p.internal = internal
   p.transform = transform
   p.inverse = inverse
   p.clone = clone

   return p
end

M.x = vector.new({1, 0, 0})
M.y = vector.new({0, 1, 0})
M.z = vector.new({0, 0, 1})

M.new = new

return M
