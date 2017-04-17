local vector = require("vector")

local M = {}

local function centroid2d(vertices, x, y)
   local s_x = 0
   local s_y = 0
   local s_a = 0

   local n = #vertices

   for i = 1, n do
      local x_i = vertices[i][x]
      local y_i = vertices[i][y]

      local x_i1 = ((i < n) and vertices[i + 1][x]) or vertices[1][x]
      local y_i1 = ((i < n) and vertices[i + 1][y]) or vertices[1][y]

      local common = x_i * y_i1 - x_i1 * y_i
      s_x = s_x + (x_i + x_i1) * common
      s_y = s_y + (y_i + y_i1) * common
      s_a = s_a + common
   end

   if s_a == 0 then
      return nil, nil
   else
      return s_x / (3 * s_a), s_y / (3 * s_a)
   end
end

local function normal(vertices)
   local a = vector.add(vertices[3], -1, vertices[2])
   local b = vector.add(vertices[1], -1, vertices[2])

   local res = vector.cross(a, b)
   return res
end

local function average(vertices)
   local res = vector.empty()

   for _, vertex in ipairs(vertices) do
      res = vector.add(res, 1, vertex)
   end

   local n = #vertices

   res[1] = res[1] / n
   res[2] = res[2] / n
   res[3] = res[3] / n

   return res
end

local function centroid(vertices)
   local res = average(vertices)

   -- for triangles the centroid is the average
   -- which we use as a backup in case the following method does not work

   if #vertices > 3 then
      -- project the polygon on the 3 axes
      local c_x1, c_y1 = centroid2d(vertices, 1, 2)
      local c_y2, c_z1 = centroid2d(vertices, 2, 3)
      local c_z2, c_x2 = centroid2d(vertices, 3, 1)

      -- if the projection is not a line
      -- the values will be computed
      -- if both values are computed, they should be the same
      res[1] = (c_x1 or c_x2) or res[1]
      res[2] = (c_y1 or c_y2) or res[2]
      res[3] = (c_z1 or c_z2) or res[3]
   end

   return res
end

M.normal = normal
M.centroid = centroid

return M
