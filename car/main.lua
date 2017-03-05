local perspective = require("perspective")
local cube = require("cube")
local canvas = require("canvas")
local position = require("position")
local vector = require("vector")

-- require("../strict")

local function init()
   local car = {}

   car.P = perspective.new()
   car.direction =  {x = 0, y = 1, z = 0}
   car.speed = 5

   car.eye = position.new({x = 11, y = -15, z = 2})

   car.centre = vector.add(car.eye.pos, car.direction)

   car.P:camera(car.eye.pos, car.centre)

   car.cnv3d = canvas.new(car.P, 500)
   car.p1 = {x = 0, y = 0, z = 0}
   car.p2 =  {x = 7, y = 9, z = 3}

   car.c1 = cube.new(car.p1, car.p2)
   car.c2 = cube.new({x = 10, y = 12, z = 0}, {x = 12, y = 0, z = -4})

   car.coeff = 0
   car.coeff_x = 0
   car.coeff_y = 0
   car.coeff_z = 0

   return car
end

local car = init()

local function infinity(cnv3d, p1, p2)
   love.graphics.setColor(0, 0, 255)

   local a4_inf = {x = p1.x, y = 10000, z = p1.z}
   local a4 = {x = p1.x, y = p2.y, z = p1.z}
   cnv3d:line(a4, a4_inf)

   local a3_inf = {x = p2.x, y = 10000, z = p1.z}
   local a3 = {x = p2.x, y = p2.y, z = p1.z}
   cnv3d:line(a3, a3_inf)

   local left_most = {x = -10000, y = 10000, z = 0}
   local right_most = {x = 10000, y = 10000, z = 0}
   cnv3d:line(left_most, right_most)
end

local function c(car)
   local p = car.P:projection(car.centre)
   local ax, ay = car.cnv3d:convert(p)
   love.graphics.setColor(255, 0, 0)
   love.graphics.circle("fill", ax, ay, 5)
end

local function fps(car, dt)
   local current = 1 / dt
   if not car.fps then
      print(dt)
      car.fps = current
   end

   local alpha = math.exp(-dt)
   car.fps = car.fps * alpha + current * (1 - alpha)
end

function love.draw()
   love.graphics.setColor(255, 255, 0)
   car.c1:draw(car.cnv3d)

   love.graphics.setColor(128, 255, 10)
   car.c2:draw(car.cnv3d)

   c(car)

   infinity(car.cnv3d, car.p1, car.p2)

   love.graphics.setColor(255, 255, 255)
   love.graphics.print("Position: " .. vector.toString(car.eye.pos, 0.01), 400, 520)
   love.graphics.print("Direction: " .. vector.toString(car.direction, 0.01), 400, 540)
   love.graphics.print("FPS: " .. math.floor(car.fps), 400, 560)
end

function love.update(dt)
   local deg = dt * math.pi / 4
   car.direction = vector.rotate(car.direction, deg * car.coeff_x, deg * car.coeff_y, deg * car.coeff_z)

   car.eye:update(dt, car.direction, car.coeff * car.speed)

   car.centre = vector.add(car.eye.pos, car.direction)
   car.P:camera(car.eye.pos, car.centre)

   fps(car, dt)
end

local leftx = "leftx"
local lefty = "lefty"
local rightx = "rightx"
local righty = "righty"

function love.gamepadaxis(joystick, axis, value)
   if axis == lefty then
      car.coeff = -value * value * value
   elseif axis == rightx then
      car.coeff_z = -value * value * value
   elseif axis == righty then
      car.coeff_x = value * value * value
   end
end

local w = "w"
local s = "s"
local up = "up"
local down = "down"
local left = "left"
local right = "right"

function love.keypressed(key)
   -- half speed with the keyboard
   if key == w then
      car.coeff = 0.5
   elseif key == s then
      car.coeff = -0.5
   elseif key == up then
      car.coeff_x = 0.5
   elseif key == down then
      car.coeff_x = -0.5
   elseif key == left then
      car.coeff_z = 0.5
   elseif key == right then
      car.coeff_z = -0.5
   end
end

function love.keyreleased(key)
   if key == w then
      car.coeff = 0
   elseif key == s then
      car.coeff = 0
   elseif key == up then
      car.coeff_x = 0
   elseif key == down then
      car.coeff_x = 0
   elseif key == left then
      car.coeff_z = 0
   elseif key == right then
      car.coeff_z = 0
   end
end
