local vector = require("vector")

local M = {}

local function toString(position)
   return "position: " .. vector.toString(position.pos)
end

local mt = { __tostring = toString }

local function update(self, dt, direction, coeff)
   self.pos = vector.add(self.pos, self.pos, dt * coeff, direction)
end

local function new(point)
   local p = {}

   setmetatable(p, mt)

   p.pos = point

   p.update = update
   return p
end

M.new = new

return M
