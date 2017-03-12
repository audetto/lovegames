local vector = require("vector")
local matrix = require("matrix")

local M = {}

local function toString(rotation)
   return "Axes: " .. matrix.toString(rotation.axes)
end

local mt = { __tostring = toString }

local function rotate(self, a, angle)
   local c = math.cos(angle)
   local s = math.sin(angle)
   local rot = matrix.new({
	 {c + a[1] * a[1] * (1 - c), a[1] * a[2] * (1 - c) - a[3] * s, a[1] * a[3] * (1 - c) + a[2] * s},
	 {a[2] * a[1] * (1 - c) + a[3] * s, c + a[2] * a[2] * (1 - c), a[2] * a[3] * (1 - c) - a[1] * s},
	 {a[3] * a[1] * (1 - c) - a[2] * s, a[3] * a[2] * (1 - c) + a[1] * s, c + a[3] * a[3] * (1 - c)}
   })

   local new = matrix.mulmm(self.work, rot, self.axes)
   self.axes, self.work = self.work, self.axes
end

local function get(self, dim)
   return self.axes[dim]
end

M.x = vector.new({1, 0, 0})
M.y = vector.new({0, 1, 0})
M.z = vector.new({0, 0, 1})

local function new()
   local p = {}

   setmetatable(p, mt)

   p.axes = matrix.new({{1, 0, 0}, {0, 1, 0}, {0, 0, 1}})
   p.work = matrix.empty()
   p.get = get
   p.rotate = rotate

   return p
end

M.new = new


return M
