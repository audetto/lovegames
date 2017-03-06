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

   c.a1 = torch.Tensor({p1[1], p1[2], p1[3]})
   c.a2 = torch.Tensor({p2[1], p1[2], p1[3]})
   c.a3 = torch.Tensor({p2[1], p2[2], p1[3]})
   c.a4 = torch.Tensor({p1[1], p2[2], p1[3]})

   c.a5 = torch.Tensor({p1[1], p1[2], p2[3]})
   c.a6 = torch.Tensor({p2[1], p1[2], p2[3]})
   c.a7 = torch.Tensor({p2[1], p2[2], p2[3]})
   c.a8 = torch.Tensor({p1[1], p2[2], p2[3]})

   return c
end

M.new = new

return M
