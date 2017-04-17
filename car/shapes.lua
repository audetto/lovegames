local vector = require("vector")
local scene = require("scene")

local M = {}

-- look here https://github.com/dcnieho/FreeGLUT/blob/git_master/freeglut/freeglut/src/fg_geometry.c

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

local function dodecahedron(color)
   local c = scene.new()

   local x = (-1 + math.sqrt(5)) / 2
   local z = ( 1 + math.sqrt(5)) / 2

   local r00 = vector.new({ 0,  z,  x})
   local r01 = vector.new({-1,  1,  1})
   local r02 = vector.new({-x,  0,  z})
   local r03 = vector.new({ x,  0,  z})
   local r04 = vector.new({ 1,  1,  1})
   local r05 = vector.new({ 0,  z, -x})
   local r06 = vector.new({ 1,  1, -1})
   local r07 = vector.new({ x,  0, -z})
   local r08 = vector.new({-x,  0, -z})
   local r09 = vector.new({-1,  1, -1})
   local r10 = vector.new({ 0, -z,  x})
   local r11 = vector.new({ 1, -1,  1})
   local r12 = vector.new({-1, -1,  1})
   local r13 = vector.new({ 0, -z, -x})
   local r14 = vector.new({-1, -1, -1})
   local r15 = vector.new({ 1, -1, -1})
   local r16 = vector.new({ z, -x,  0})
   local r17 = vector.new({ z,  x,  0})
   local r18 = vector.new({-z,  x,  0})
   local r19 = vector.new({-z, -x,  0})

   c:addFace(color, r00, r01, r02, r03, r04)
   c:addFace(color, r05, r06, r07, r08, r09)
   c:addFace(color, r10, r11, r03, r02, r12)
   c:addFace(color, r13, r14, r08, r07, r15)

   c:addFace(color, r03, r11, r16, r17, r04)
   c:addFace(color, r02, r01, r18, r19, r12)
   c:addFace(color, r07, r06, r17, r16, r15)
   c:addFace(color, r08, r14, r19, r18, r09)

   c:addFace(color, r17, r06, r05, r00, r04)
   c:addFace(color, r16, r11, r10, r13, r15)
   c:addFace(color, r18, r01, r00, r05, r09)
   c:addFace(color, r19, r14, r13, r10, r12)

   return c
end

local function icosahedron(color)
   local c = scene.new()

   -- would be nice to know where they come from
   local u = 0.276393202252
   local v = 0.447213595500
   local w = 0.525731112119
   local x = 0.723606797748
   local y = 0.850650808354
   local z = 0.894427191000

   local r00 = vector.new({ 1,  0,  0})
   local r01 = vector.new({ v,  z,  0})
   local r02 = vector.new({ v,  u,  y})
   local r03 = vector.new({ v, -x,  w})
   local r04 = vector.new({ v, -x, -w})
   local r05 = vector.new({ v,  u, -y})
   local r06 = vector.new({-v, -z,  0})
   local r07 = vector.new({-v, -u,  y})
   local r08 = vector.new({-v,  x,  w})
   local r09 = vector.new({-v,  x, -w})
   local r10 = vector.new({-v, -u, -y})
   local r11 = vector.new({-1,  0,  0})

   c:addFace(color, r00, r01, r02)
   c:addFace(color, r00, r02, r03)
   c:addFace(color, r00, r03, r04)
   c:addFace(color, r00, r04, r05)
   c:addFace(color, r00, r05, r01)
   c:addFace(color, r01, r08, r02)
   c:addFace(color, r02, r07, r03)
   c:addFace(color, r03, r06, r04)
   c:addFace(color, r04, r10, r05)
   c:addFace(color, r05, r09, r01)
   c:addFace(color, r01, r09, r08)
   c:addFace(color, r02, r08, r07)
   c:addFace(color, r03, r07, r06)
   c:addFace(color, r04, r06, r10)
   c:addFace(color, r05, r10, r09)
   c:addFace(color, r11, r09, r10)
   c:addFace(color, r11, r08, r09)
   c:addFace(color, r11, r07, r08)
   c:addFace(color, r11, r06, r07)
   c:addFace(color, r11, r10, r06)

   return c
end

M.cube = cube
M.tetrahedron = tetrahedron
M.octahedron = octahedron
M.dodecahedron = dodecahedron
M.icosahedron = icosahedron

return M
