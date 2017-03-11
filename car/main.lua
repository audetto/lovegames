local perspective = require("perspective")
local cube = require("cube")
local canvas = require("canvas")
local position = require("position")
local vector = require("vector")
local clock = require("clock")
local colors = require("colors")
local torch = require("torch")
local rotation = require("rotation")

-- missing strict is not an error
pcall(function() require("strict") end)

local function viewfinder()
   local points = {}

   local size = 0.5
   local dist = 10

   local a1 = torch.Tensor({-size, dist, 0})
   local b1 = torch.Tensor({size, dist, 0})
   table.insert(points, {a = a1, b = b1, relative = true})

   local a2 = torch.Tensor({0, dist, size})
   local b2 = torch.Tensor({0, dist, -size})
   table.insert(points, {a = a2, b = b2, relative = true})

   return points
end

local function boundaries(p1, p2)
   local points = {}

   love.graphics.setColor(colors.gray)

   local inf = 100

   local a4_inf = torch.Tensor({p1[1], inf, p1[3]})
   local a4 = torch.Tensor({p1[1], p2[2], p1[3]})
   table.insert(points, {a = a4, b = a4_inf, color = colors.gray})

   local a3_inf = torch.Tensor({p2[1], inf, p1[3]})
   local a3 = torch.Tensor({p2[1], p2[2], p1[3]})
   table.insert(points, {a = a3, b = a3_inf, color = colors.gray})

   local left_most_ahead = torch.Tensor({-inf, inf, 0})
   local right_most_ahead = torch.Tensor({inf, inf, 0})
   local left_most_behind = torch.Tensor({-inf, -inf, 0})
   local right_most_behind = torch.Tensor({inf, -inf, 0})

   table.insert(points, {a = left_most_ahead, b = right_most_ahead, color = colors.magenta})
   table.insert(points, {a = right_most_ahead, b = right_most_behind, color = colors.maroon})
   table.insert(points, {a = right_most_behind, b = left_most_behind, color = colors.purple})
   table.insert(points, {a = left_most_behind, b = left_most_ahead, color = colors.teal})

   return points
end

local function init()
   local car = {}

   car.P = perspective.new()
   car.axes = rotation.new()
   car.dir_sign = 1
   car.speed = 5
   car.north = torch.Tensor({0, 0, 1})

   car.eye = position.new(torch.Tensor({11, -15, 2}))

   car.cnv3d = canvas.new(car.P, 500)

   local p1 = torch.Tensor({0, 0, 0})
   local p2 =  torch.Tensor({7, 9, 3})

   car.c1 = cube.new(p1, p2)
   car.c2 = cube.new(torch.Tensor({10, 12, 0}), torch.Tensor({12, 0, -4}))
   car.c3 = cube.new(torch.Tensor({5, 12, 10}), torch.Tensor({12, 20, 14}))

   car.viewfinder = viewfinder()
   car.boundaries = boundaries(p1, p2)

   local pos_clock = torch.Tensor({0, 50, 30})

   car.clock = clock.new(pos_clock, 20)

   car.coeff = 0
   car.coeff_x = 0
   car.coeff_y = 0
   car.coeff_z = 0

   return car
end

local car = init()

function love.draw()
   love.graphics.setColor(colors.yellow)
   car.c1:draw(car.cnv3d)

   love.graphics.setColor(colors.silver)
   car.c2:draw(car.cnv3d)
   car.c3:draw(car.cnv3d)

   car.cnv3d:lines(car.boundaries)

   car.clock:draw(car.cnv3d)

   if car.dir_sign > 0 then
      love.graphics.setColor(colors.red)
   else
      love.graphics.setColor(colors.cyan)
   end

   car.cnv3d:lines(car.viewfinder)

   love.graphics.setColor(colors.white)

   love.graphics.print("Position: " .. vector.toString(car.eye.pos), 400, 500)
   love.graphics.print("Direction: " .. vector.toString(car.axes:get(2)), 400, 515)
   love.graphics.print("Norm: " .. car.axes:get(2):norm(), 400, 530)
   local angle = vector.angle(car.axes:get(2), car.north) / (math.pi * 2) * 360
   love.graphics.print(string.format("North: %6.1f", angle), 400, 545)
   love.graphics.print("FPS: " .. love.timer.getFPS(), 400, 560)
end

function love.update(dt)
   local deg = dt * math.pi / 4

   car.axes:rotate(rotation.x, deg * car.coeff_x)
   car.axes:rotate(rotation.z, -deg * car.coeff_z)

   car.eye:update(dt, car.axes:get(2), car.coeff * car.speed)

   car.P:camera(car.eye.pos, car.axes, car.dir_sign)
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
