local vector = require("vector")
local scene = require("scene")

local M = {}

local function cube(mode, color, p1, p2)
   local c = scene.new()

   local a1 = vector.new({p1[1], p1[2], p1[3]})
   local a2 = vector.new({p2[1], p1[2], p1[3]})
   local a3 = vector.new({p2[1], p2[2], p1[3]})
   local a4 = vector.new({p1[1], p2[2], p1[3]})

   local a5 = vector.new({p1[1], p1[2], p2[3]})
   local a6 = vector.new({p2[1], p1[2], p2[3]})
   local a7 = vector.new({p2[1], p2[2], p2[3]})
   local a8 = vector.new({p1[1], p2[2], p2[3]})

   if mode == "line" then
      c:addLine(color, a1, a2)
      c:addLine(color, a2, a3)
      c:addLine(color, a3, a4)
      c:addLine(color, a4, a1)

      c:addLine(color, a5, a6)
      c:addLine(color, a6, a7)
      c:addLine(color, a7, a8)
      c:addLine(color, a8, a5)

      c:addLine(color, a1, a5)
      c:addLine(color, a2, a6)
      c:addLine(color, a3, a7)
      c:addLine(color, a4, a8)
   else
      c:addFace(color, a1, a4, a3, a2)
      c:addFace(color, a6, a5, a1, a2)
      c:addFace(color, a7, a6, a2, a3)
      c:addFace(color, a8, a7, a3, a4)
      c:addFace(color, a5, a8, a4, a1)
      c:addFace(color, a7, a8, a5, a6)
   end

   return c
end

M.cube = cube

return M
