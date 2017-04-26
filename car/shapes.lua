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

   local vertices = {a0, a1, a2, a3, a4, a5, a6, a7}

   local indexFaces = {
      {vertices = {1, 2, 3, 4}, color = color},
      {vertices = {1, 4, 5, 6}, color = color},
      {vertices = {1, 6, 7, 2}, color = color},
      {vertices = {2, 7, 8, 3}, color = color},
      {vertices = {8, 5, 4, 3}, color = color},
      {vertices = {5, 8, 7, 6}, color = color}
   }

   c:addVertexArray(vertices, indexFaces)

   return c
end

local function tetrahedron(color)
   local c = scene.new()

   local r0 = vector.new({                  0,                    0,      1})
   local r1 = vector.new({                  0, 2 * math.sqrt(2) / 3, -1 / 3})
   local r2 = vector.new({   math.sqrt(6) / 3,   - math.sqrt(2) / 3, -1 / 3})
   local r3 = vector.new({ - math.sqrt(6) / 3,   - math.sqrt(2) / 3, -1 / 3})

   local vertices = {r0, r1, r2, r3}
   local indexFaces = {
      {vertices = {2, 3, 4}, color = color},
      {vertices = {1, 4, 3}, color = color},
      {vertices = {1, 2, 4}, color = color},
      {vertices = {1, 3, 2}, color = color}
   }

   c:addVertexArray(vertices, indexFaces)

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

   local vertices = {r0, r1, r2, r3, r4, r5}

   local indexFaces = {
      {vertices = {1, 2, 3}, color = color},
      {vertices = {1, 6, 2}, color = color},
      {vertices = {1, 3, 5}, color = color},
      {vertices = {1, 5, 6}, color = color},
      {vertices = {4, 3, 2}, color = color},
      {vertices = {4, 2, 6}, color = color},
      {vertices = {4, 5, 3}, color = color},
      {vertices = {4, 6, 5}, color = color}
   }

   c:addVertexArray(vertices, indexFaces)

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

   local vertices = {
      r00, r01, r02, r03, r04, r05, r06, r07, r08, r09,
      r10, r11, r12, r13, r14, r15, r16, r17, r18, r19
   }

   local indexFaces = {
      {vertices = {01, 02, 03, 04, 05}, color = color},
      {vertices = {06, 07, 08, 09, 10}, color = color},
      {vertices = {11, 12, 04, 03, 13}, color = color},
      {vertices = {14, 15, 09, 08, 16}, color = color},

      {vertices = {04, 12, 17, 18, 05}, color = color},
      {vertices = {03, 02, 19, 20, 13}, color = color},
      {vertices = {08, 07, 18, 17, 16}, color = color},
      {vertices = {09, 15, 20, 19, 10}, color = color},

      {vertices = {18, 07, 06, 01, 05}, color = color},
      {vertices = {17, 12, 11, 14, 16}, color = color},
      {vertices = {19, 02, 01, 06, 10}, color = color},
      {vertices = {20, 15, 14, 11, 13}, color = color}
   }

   c:addVertexArray(vertices, indexFaces)

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

   local vertices = {r00, r01, r02, r03, r04, r05, r06, r07, r08, r09, r10, r11}
   local indexFaces = {
      {vertices = {01, 02, 03}, color = color},
      {vertices = {01, 03, 04}, color = color},
      {vertices = {01, 04, 05}, color = color},
      {vertices = {01, 05, 06}, color = color},

      {vertices = {01, 06, 02}, color = color},
      {vertices = {02, 09, 03}, color = color},
      {vertices = {03, 08, 04}, color = color},
      {vertices = {04, 07, 05}, color = color},

      {vertices = {05, 11, 06}, color = color},
      {vertices = {06, 10, 02}, color = color},
      {vertices = {02, 10, 09}, color = color},
      {vertices = {03, 09, 08}, color = color},

      {vertices = {04, 08, 07}, color = color},
      {vertices = {05, 07, 11}, color = color},
      {vertices = {06, 11, 10}, color = color},
      {vertices = {12, 10, 11}, color = color},

      {vertices = {12, 09, 10}, color = color},
      {vertices = {12, 08, 09}, color = color},
      {vertices = {12, 07, 08}, color = color},
      {vertices = {12, 11, 07}, color = color},
   }

   c:addVertexArray(vertices, indexFaces)

   return c
end

M.cube = cube
M.tetrahedron = tetrahedron
M.octahedron = octahedron
M.dodecahedron = dodecahedron
M.icosahedron = icosahedron

return M
