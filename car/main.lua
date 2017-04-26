-- missing strict is not an error
pcall(function() require("strict") end)

local perspective = require("perspective")
local shapes = require("shapes")
local canvas = require("canvas")
local transformation = require("transformation")
local vector = require("vector")
local clock = require("clock")
local colors = require("colors")
local scene = require("scene")

local car

local function viewfinder(color, dist)
   local points = scene.new()

   local size = 0.05

   local a1 = vector.new({-size, dist, 0})
   local b1 = vector.new({size, dist, 0})

   local a2 = vector.new({0, dist, size})
   local b2 = vector.new({0, dist, -size})

   local vertices = {a1, b1, a2, b2}

   local indexLines = {
      {vertices = {1, 2}, color = color},
      {vertices = {3, 4}, color = color}
   }

   points:addVertexLines(vertices, indexLines)

   return points
end

local function boundaries(p1, p2)
   local points = scene.new()

   local inf = 100

   local a4_inf = vector.new({p1[1], inf, p1[3]})
   local a4 = vector.new({p1[1], p2[2], p1[3]})

   local a3_inf = vector.new({p2[1], inf, p1[3]})
   local a3 = vector.new({p2[1], p2[2], p1[3]})

   local left_most_ahead = vector.new({-inf, inf, 0})
   local right_most_ahead = vector.new({inf, inf, 0})
   local left_most_behind = vector.new({-inf, -inf, 0})
   local right_most_behind = vector.new({inf, -inf, 0})

   local vertices = {a4_inf, a4, a3_inf, a3,
		     left_most_ahead, right_most_ahead,
		     right_most_behind, left_most_behind}

   local indexLines = {
      {vertices = {1, 2}, color = colors.gray},
      {vertices = {3, 4}, color = colors.gray},
      {vertices = {5, 6}, color = colors.magenta},
      {vertices = {6, 7}, color = colors.gray},
      {vertices = {7, 8}, color = colors.gray},
      {vertices = {8, 5}, color = colors.gray}
   }

   points:addVertexLines(vertices, indexLines)

   return points
end

local function player()
   local p = scene.new()

   local c = shapes.cube(colors.red)
   c:scale({2, 3, 1})
   p:addScene(c)

   local t = shapes.tetrahedron(colors.blue)
   t:scale({1, 3, 1})
   t:translate(transformation.z, 0.5 + 1 / 3)
   p:addScene(t)

   p:translate(transformation.y, 8)
   p:translate(transformation.z, -5)

   p:apply()

   return p
end

local function init()
   local car = {}

   car.P = perspective.new()
   car.dir_sign = 1
   car.speed = 5
   car.north = vector.new({0, 0, 1})

   car.camera = transformation.new()
   car.camera:translate(vector.new({11, -15, 2}), 1)

   car.cnv3d = canvas.new(car.P, 500)

   car.static = scene.new()
   local viewfinder1 = viewfinder(colors.red, 1) -- ahead
   car.static:addScene(viewfinder1)

   local viewfinder2 = viewfinder(colors.green, -1) -- behind
   car.static:addScene(viewfinder2)

   car.world = scene.new()

   car.player = player()
   car.world:addScene(car.player)

   local c1 = shapes.cube(colors.yellow)
   c1:translate(vector.new({3.5, 4.5, 1.5}), 1)
   c1:scale({7, 9, 3})

   car.world:addScene(c1)

   local c2 = shapes.cube(colors.silver)
   c2:translate(vector.new({11, 6, -2}), 1)
   c2:scale({2, 12, 4})

   car.world:addScene(c2)

   local c3 = shapes.cube(colors.silver)
   c3:translate(vector.new({8.5, 16, 12}), 1)
   c3:scale({7, 8, 4})

   car.world:addScene(c3)

   local c4 = shapes.cube(colors.red)
   c4:translate(vector.new({11, 24, -2}), 1)
   c4:scale({2, 12, 4})

   car.world:addScene(c4)

   car.t1 = shapes.tetrahedron(colors.blue)
   car.t1:translate(vector.new({20, 20, 0}), 1)
   car.t1:scale({5, 5, 5})

   car.world:addScene(car.t1)

   local o1 = shapes.octahedron(colors.cyan)
   o1:translate(vector.new({-20, 20, 0}), 1)
   o1:scale({6, 6, 6})

   car.world:addScene(o1)

   car.d1 = shapes.dodecahedron(colors.lime)
   car.d1:translate(vector.new({-20, 70, 30}), 1)
   car.d1:scale({6, 6, 6})

   car.world:addScene(car.d1)

   car.i1 = shapes.icosahedron(colors.olive)
   car.i1:translate(vector.new({30, 20, 10}), 1)
   car.i1:scale({7, 7, 7})

   car.world:addScene(car.i1)

   local p1 = vector.new({0, 0, 0})
   local p2 = vector.new({7, 9, 3})
   local boundaries = boundaries(p1, p2)

   car.world:addScene(boundaries)

   local pos_clock = vector.new({0, 50, 30})
   car.clock = clock.new(pos_clock, 20)

   car.coeff = 0
   car.coeff_x = 0
   car.coeff_y = 0
   car.coeff_z = 0

   return car
end

function love.load()
   car = init()
end

function love.draw()
   car.P.sign = car.dir_sign

   -- these are drawn before the center of the world
   -- i.e. relative to camera
   car.static:draw(car.cnv3d)

   -- from camera to the center of the world
   car.cnv3d:push(car.camera:inverse())

   car.world:draw(car.cnv3d)
   car.clock:draw(car.cnv3d)

   car.cnv3d:pop()

   car.cnv3d:draw()

   love.graphics.setColor(colors.white)

   local position = car.camera:getPos()
   local direction = car.camera:getY()

   love.graphics.print("Position: " .. tostring(position), 400, 500)
   love.graphics.print("Direction: " .. tostring(direction), 400, 515)
   love.graphics.print("Norm: " .. direction:norm(), 400, 530)
   local angle = vector.angle(direction, car.north) / (math.pi * 2) * 360
   love.graphics.print(string.format("North: %6.1f", angle), 400, 545)
   love.graphics.print("FPS: " .. love.timer.getFPS(), 400, 560)
end

function love.update(dt)
   local deg = dt * math.pi / 4

   car.t1:rotate(transformation.y, 2 * deg)
   car.t1:rotate(transformation.x, deg)
   car.t1:rotate(transformation.z, deg / 2)

   car.d1:rotate(transformation.x, deg)
   car.i1:rotate(transformation.z, deg)

   -- rotate around local x and z
   car.camera:rotate(transformation.x, deg * car.coeff_x)
   car.camera:rotate(transformation.z, -deg * car.coeff_z)

   -- move along local y
   car.camera:translate(transformation.y, dt * car.coeff * car.speed)

   car.player.transformation = car.camera
end

function love.gamepadaxis(joystick, axis, value)
   if axis == "lefty" then
      car.coeff = -value * value * value
   elseif axis == "rightx" then
      car.coeff_z = value * value * value
   elseif axis == "righty" then
      car.coeff_x = -value * value * value
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
