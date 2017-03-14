local vector = require("vector")

local M = {}

local function normal(vertices)
   local a = vector.empty()
   a = vector.add(a, vertices[3], -1, vertices[2])
   local b = vector.empty()
   b = vector.add(b, vertices[1], -1, vertices[2])

   local res = vector.cross(a, b)
   return res
end

local function centroid(vertices, k, h)
   local res = vector.empty()

   -- this is correct only for RECTANGLES
   -- needs to be fixed
   for _, vertex in ipairs(vertices) do
      res = vector.add(res, res, 1, vertex)
   end

   local n = #vertices

   res[1] = res[1] / n
   res[2] = res[2] / n
   res[3] = res[3] / n

   return res
end

M.normal = normal
M.centroid = centroid

return M
