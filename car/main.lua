local perspective = require("perspective")
local shapes = require("shapes")
local canvas = require("canvas")
local transformation = require("transformation")
local vector = require("vector")
local matrix = require("matrix")
local clock = require("clock")
local colors = require("colors")
local scene = require("scene")

-- missing strict is not an error
pcall(function() require("strict") end)

local function viewfinder()
   local points = scene.new()

   local size = 0.05
   local dist = 1

   local a1 = vector.new({-size, dist, 0})
   local b1 = vector.new({size, dist, 0})
   points:addLine(colors.red, a1, b1, true)

   local a2 = vector.new({0, dist, size})
   local b2 = vector.new({0, dist, -size})
   points:addLine(colors.red, a2, b2, true)

   return points
end

local function boundaries(p1, p2)
   local points = scene.new()

   love.graphics.setColor(colors.gray)

   local inf = 100

   local a4_inf = vector.new({p1[1], inf, p1[3]})
   local a4 = vector.new({p1[1], p2[2], p1[3]})
   points:addLine(colors.gray, a4, a4_inf)

   local a3_inf = vector.new({p2[1], inf, p1[3]})
   local a3 = vector.new({p2[1], p2[2], p1[3]})
   points:addLine(colors.gray, a3, a3_inf)

   local left_most_ahead = vector.new({-inf, inf, 0})
   local right_most_ahead = vector.new({inf, inf, 0})
   local left_most_behind = vector.new({-inf, -inf, 0})
   local right_most_behind = vector.new({inf, -inf, 0})

   points:addLine(colors.magenta, left_most_ahead, right_most_ahead)
   points:addLine(colors.gray, right_most_ahead, right_most_behind)
   points:addLine(colors.gray, right_most_behind, left_most_behind)
   points:addLine(colors.gray, left_most_behind, left_most_ahead)

   return points
end

local function init()
   local car = {}

   car.P = perspective.new()
   car.dir_sign = 1
   car.speed = 5
   car.north = vector.new({0, 0, 1})

   car.camera = transformation.new(vector.new({11, -15, 2}))

   car.cnv3d = canvas.new(car.P, 500)

   local p1 = vector.new({0, 0, 0})
   local p2 = vector.new({7, 9, 3})

   car.c1 = shapes.cube(colors.yellow)
   car.c1:rotate(matrix.diag({7, 9, 3}))
   car.c1:translate(vector.new({3.5, 4.5, 1.5}))

   car.c2 = shapes.cube(colors.silver)
   car.c2:rotate(matrix.diag({2, 12, 4}))
   car.c2:translate(vector.new({11, 6, -2}))

   car.c3 = shapes.cube(colors.silver)
   car.c3:rotate(matrix.diag({7, 8, 4}))
   car.c3:translate(vector.new({8.5, 16, 12}))

   car.c4 = shapes.cube(colors.red)
   car.c4:rotate(matrix.diag({2, 12, 4}))
   car.c4:translate(vector.new({11, 24, -2}))

   car.t1 = shapes.tetrahedron(colors.blue)
   car.o1 = shapes.octahedron(colors.cyan)

   car.t1:rotate(matrix.diag({5, 5, 5}))
   car.t1:translate(vector.new({20, 20, 0}))

   car.o1:rotate(matrix.diag({6, 6, 6}))
   car.o1:translate(vector.new({-20, 20, 0}))

   car.viewfinder = viewfinder()
   car.boundaries = boundaries(p1, p2)

   local pos_clock = vector.new({0, 50, 30})

   car.clock = clock.new(pos_clock, 20)

   car.coeff = 0
   car.coeff_x = 0
   car.coeff_y = 0
   car.coeff_z = 0

   return car
end

local car = init()

function love.draw()
   car.c1:draw(car.cnv3d)
   car.c2:draw(car.cnv3d)
   car.c3:draw(car.cnv3d)
   car.c4:draw(car.cnv3d)
   car.t1:draw(car.cnv3d)
   car.o1:draw(car.cnv3d)

   car.clock:draw(car.cnv3d)
   car.boundaries:draw(car.cnv3d)
   car.viewfinder:draw(car.cnv3d)

   car.cnv3d:draw()

   love.graphics.setColor(colors.white)

   local direction = car.camera:getY()

   love.graphics.print("Position: " .. tostring(car.camera.translation), 400, 500)
   love.graphics.print("Direction: " .. tostring(direction), 400, 515)
   love.graphics.print("Norm: " .. direction:norm(), 400, 530)
   local angle = direction:angle(car.north) / (math.pi * 2) * 360
   love.graphics.print(string.format("North: %6.1f", angle), 400, 545)
   love.graphics.print("FPS: " .. love.timer.getFPS(), 400, 560)
end

function love.update(dt)
   local deg = dt * math.pi / 4

   car.camera:rotate(transformation.x, deg * car.coeff_x)
   car.camera:rotate(transformation.z, -deg * car.coeff_z)

   local rot = matrix.rotation(transformation.y, deg)
   car.t1:rotate(rot)

   car.camera:translate(car.camera:getY(), dt * car.coeff * car.speed)

   car.P:setCamera(car.camera, car.dir_sign)
end

function love.gamepadaxis(joystick, axis, value)
   if axis == "lefty" then
      car.coeff = -value * value * value
   elseif axis == "rightx" then
      car.coeff_z = -value * value * value
   elseif axis == "righty" then
      car.coeff_x = value * value * value
   end
end

function love.keypressed(key)
   -- half speed with the keyboard
   if key == "w" then
      car.coeff = 0.5
   elseif key == "s" then
      car.coeff = -0.5
   elseif key == "up" then
      car.coeff_x = 0.5
   elseif key == "down" then
      car.coeff_x = -0.5
   elseif key == "left" then
      car.coeff_z = 0.5
   elseif key == "right" then
      car.coeff_z = -0.5
   end
end

function love.keyreleased(key)
   if key == "w" then
      car.coeff = 0
   elseif key == "s" then
      car.coeff = 0
   elseif key == "up" then
      car.coeff_x = 0
   elseif key == "down" then
      car.coeff_x = 0
   elseif key == "left" then
      car.coeff_z = 0
   elseif key == "right" then
      car.coeff_z = 0
   end
end

function love.gamepadreleased(joystick, button)
   if button == "a" then
      -- look backward
      car.dir_sign = 1
   end
end

function love.gamepadpressed(joystick, button)
   if button == "a" then
      car.dir_sign = -1
   end
end
