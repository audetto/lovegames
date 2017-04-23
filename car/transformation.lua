local vector = require("vector")
local matrix = require("matrix")

local M = {}

local function toString(self)
   return "Rotation: " .. matrix.toString(self.rotation)
end

local mt = { __tostring = toString }

local function translate(self, direction, coeff)
   if coeff == 0 then
      return
   end

   local rot = matrix.translation(direction, coeff)
   self:generic(rot)
end

local function rotate(self, a, angle)
   if angle == 0 then
      return
   end

   local rot = matrix.rotation(a, angle)
   self:generic(rot)
end

local function scale(self, s)
   local rot = matrix.diag(s)
   self:generic(rot)
end

local function generic(self, m)
   -- postmultiply to rotate around local axes
   self.rotation = matrix.mulmm(self.rotation, m)
end

local function getY(self)
   return self.rotation:column(2)
end

local function transform(self, x)
   return matrix.mulmv(self.rotation, x)
end

local function new(rot)
   local p = {}

   setmetatable(p, mt)

   p.rotation = rot or matrix.id()

   p.getY = getY
   p.rotate = rotate
   p.translate = translate
   p.scale = scale
   p.generic = generic
   p.transform = transform

   return p
end

local function inverse(self)
   local rot = matrix.inverse(self.rotation)
   return new(rot)
end

M.x = vector.new({1, 0, 0})
M.y = vector.new({0, 1, 0})
M.z = vector.new({0, 0, 1})

M.new = new
M.inverse = inverse

return M
