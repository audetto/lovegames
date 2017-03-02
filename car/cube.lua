local M = {}

local function draw(self, canvas3d)
   canvas3d:line(self.a1, self.a2)
   canvas3d:line(self.a2, self.a3)
   canvas3d:line(self.a3, self.a4)
   canvas3d:line(self.a4, self.a1)

   canvas3d:line(self.a5, self.a6)
   canvas3d:line(self.a6, self.a7)
   canvas3d:line(self.a7, self.a8)
   canvas3d:line(self.a8, self.a5)

   canvas3d:line(self.a1, self.a5)
   canvas3d:line(self.a2, self.a6)
   canvas3d:line(self.a3, self.a7)
   canvas3d:line(self.a4, self.a8)
end

local function new(p1, p2)
   local c = {}
   c.draw = draw

   c.a1 = {x = p1.x, y = p1.y, z = p1.z}
   c.a2 = {x = p2.x, y = p1.y, z = p1.z}
   c.a3 = {x = p2.x, y = p2.y, z = p1.z}
   c.a4 = {x = p1.x, y = p2.y, z = p1.z}

   c.a5 = {x = p1.x, y = p1.y, z = p2.z}
   c.a6 = {x = p2.x, y = p1.y, z = p2.z}
   c.a7 = {x = p2.x, y = p2.y, z = p2.z}
   c.a8 = {x = p1.x, y = p2.y, z = p2.z}

   return c
end

M.new = new

return M
