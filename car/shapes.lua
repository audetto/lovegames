local vector = require("vector")
local scene = require("scene")

local M = {}

local function cube(color)
   local c = scene.new()

   local a0 = vector.new({ 0.5,  0.5,  0.5})
   local a1 = vector.new({-0.5,  0.5,  0.5})
   local a2 = vector.new({-0.5, -0.5, 00.5})
   local a3 = vector.new({ 0.5, -0.5,  0.5})
   local a4 = vector.new({ 0.5, -0.5, -0.5})
   local a5 = vector.new({ 0.5,  0.5, -0.5})
   local a6 = vector.new({-0.5,  0.5, -0.5})
   local a7 = vector.new({-0.5, -0.5, -0.5})

   c:addFace(color, a0, a1, a2, a3)
   c:addFace(color, a0, a3, a4, a5)
   c:addFace(color, a0, a5, a6, a1)
   c:addFace(color, a1, a6, a7, a2)
   c:addFace(color, a7, a4, a3, a2)
   c:addFace(color, a4, a7, a6, a5)

   return c
end

local function tetrahedron(color)
   local c = scene.new()

   local r0 = vector.new({     1,                    0,                  0})
   local r1 = vector.new({-1 / 3, 2 * math.sqrt(2) / 3,                  0})
   local r2 = vector.new({-1 / 3,   - math.sqrt(2) / 3,   math.sqrt(6) / 3})
   local r3 = vector.new({-1 / 3,   - math.sqrt(2) / 3, - math.sqrt(6) / 3})

   c:addFace(color, r1, r3, r2)
   c:addFace(color, r0, r2, r3)
   c:addFace(color, r0, r3, r1)
   c:addFace(color, r0, r1, r2)

   return c
end

local function octahedron(color)
   local c = scene.new()

   local r0 = vector.new({ 1,  0,  0})
   local r1 = vector.new({ 0,  1,  0})
   local r2 = vector.new({ 0,  0,  1})
   local r3 = vector.new({-1,  0,  0})
   local r4 = vector.new({ 0, -1,  0})
   local r5 = vector.new({ 0,  0, -1})

   c:addFace(color, r0, r1, r2)
   c:addFace(color, r0, r5, r1)
   c:addFace(color, r0, r2, r4)
   c:addFace(color, r0, r4, r5)
   c:addFace(color, r3, r2, r1)
   c:addFace(color, r3, r1, r5)
   c:addFace(color, r3, r4, r2)
   c:addFace(color, r3, r5, r4)

   return c
end

M.cube = cube
M.tetrahedron = tetrahedron
M.octahedron = octahedron

return M
