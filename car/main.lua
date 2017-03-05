local perspective = require("perspective")
local cube = require("cube")
local canvas = require("canvas")
local position = require("position")
local vector = require("vector")
local clock = require("clock")
local colors = require("colors")

require("../strict")

local function viewfinder()
   local points = {}

   local size = 0.5
   local dist = 10

   local a1 = {x = -size, y = dist, z = 0}
   local b1 = {x = size, y = dist, z = 0}
   table.insert(points, {a = a1, b = b1, relative = true})

   local a2 = {x = 0, y = dist, z = size}
   local b2 = {x = 0, y = dist, z = -size}
   table.insert(points, {a = a2, b = b2, relative = true})

   return points
end

local function boundaries(p1, p2)
   local points = {}

   love.graphics.setColor(colors.gray)

   local inf = 100

   local a4_inf = {x = p1.x, y = inf, z = p1.z}
   local a4 = {x = p1.x, y = p2.y, z = p1.z}
   table.insert(points, {a = a4, b = a4_inf, color = colors.gray})

   local a3_inf = {x = p2.x, y = inf, z = p1.z}
   local a3 = {x = p2.x, y = p2.y, z = p1.z}
   table.insert(points, {a = a3, b = a3_inf, color = colors.gray})

   local left_most_ahead = {x = -inf, y = inf, z = 0}
   local right_most_ahead = {x = inf, y = inf, z = 0}
   local left_most_behind = {x = -inf, y = -inf, z = 0}
   local right_most_behind = {x = inf, y = -inf, z = 0}

   table.insert(points, {a = left_most_ahead, b = right_most_ahead, color = colors.magenta})
   table.insert(points, {a = right_most_ahead, b = right_most_behind, color = colors.maroon})
   table.insert(points, {a = right_most_behind, b = left_most_behind, color = colors.purple})
   table.insert(points, {a = left_most_behind, b = left_most_ahead, color = colors.teal})

   return points
end

local function init()
   local car = {}

   car.P = perspective.new()
   car.direction = {x = 0, y = 1, z = 0}
   car.dir_sign = 1
   car.speed = 5
   car.north = {x = 0, y = 0, z = 1}

   car.eye = position.new({x = 11, y = -15, z = 2})
   car.P:camera(car.eye.pos, car.direction, car.dir_sign)

   car.cnv3d = canvas.new(car.P, 500)

   local p1 = {x = 0, y = 0, z = 0}
   local p2 =  {x = 7, y = 9, z = 3}

   car.c1 = cube.new(p1, p2)
   car.c2 = cube.new({x = 10, y = 12, z = 0}, {x = 12, y = 0, z = -4})

   car.viewfinder = viewfinder()
   car.boundaries = boundaries(p1, p2)

   local pos_clock = {x = 0, y = 50, z = 30}

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
   love.graphics.print("Direction: " .. vector.toString(car.direction), 400, 515)
   local angle = vector.angle(car.direction, car.north) / (math.pi * 2) * 360
   love.graphics.print(string.format("North: %6.1f", angle), 400, 530)
   love.graphics.print("FPS: " .. love.timer.getFPS(), 400, 545)
end

function love.update(dt)
   local deg = dt * math.pi / 4
   -- needs to be simplified!
   local relative = car.P:rotation(car.direction)
   relative = vector.rotate(relative, deg * car.coeff_x, deg * car.coeff_y, deg * car.coeff_z)
   car.direction = car.P:rotation(relative, -1)

   car.eye:update(dt, car.direction, car.coeff * car.speed)

   car.P:camera(car.eye.pos, car.direction, car.dir_sign)
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
