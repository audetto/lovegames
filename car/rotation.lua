local vector = require("vector")
local torch = require("torch")

local M = {}

local function toString(position)
   return "position: " .. vector.toString(position.pos)
end

local mt = { __tostring = toString }

local function rotate(self, a, angle)
   local c = math.cos(angle)
   local s = math.sin(angle)
   local rot = torch.Tensor({
	 {c + a[1] * a[1] * (1 - c), a[1] * a[2] * (1 - c) - a[3] * s, a[1] * a[3] * (1 - c) + a[2] * s},
	 {a[2] * a[1] * (1 - c) + a[3] * s, c + a[2] * a[2] * (1 - c), a[2] * a[3] * (1 - c) - a[1] * s},
	 {a[3] * a[1] * (1 - c) - a[2] * s, a[3] * a[2] * (1 - c) + a[1] * s, c + a[3] * a[3] * (1 - c)}
   })

   self.axes = rot * self.axes
end

local function get(self, dim)
   return self.axes[dim]
end

M.x = {1, 0, 0}
M.y = {0, 1, 0}
M.z = {0, 0, 1}

local function new()
   local p = {}

   setmetatable(p, mt)

   p.axes = torch.Tensor({M.x, M.y, M.z})
   p.get = get
   p.rotate = rotate

   return p
end

M.new = new


return M
