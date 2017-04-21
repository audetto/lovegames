local M = {}

local getinfo = debug.getinfo

local CALL = "call"
local RETURN = "return"
local LUA = "Lua"

local function was_that_a_tailcall(self)
   local tail = getinfo(self.level - self.extra + self.depth, "l") == nil
   return tail
end

local function find_stack_depth()
   local i = 0
   repeat
      i = i + 1
      local a = getinfo(i, "l")
   until a == nil
   return i - 1
end

local function hook(event)
   local info = getinfo(2, "nfS")

   if info.what == LUA then
      local clock = os.clock()
      local func = info.func

      if not M.ids[func] then
	 local name = tostring(info.name) .. info.source .. ":" .. info.linedefined
	 M.ids[func] = {name = name, time = 0, calls = 0, open = 0}
      end

      local id = M.ids[func]

      if event == CALL then
	 M.level = M.level + 1
	 local tail = was_that_a_tailcall(M)
	 if tail then
	    M.extra = M.extra + 1
	 end
	 id.calls = id.calls + 1
	 id.open = id.open + 1
	 id.time = id.time - clock

	 M.stack[M.level] = {func, tail}
      elseif event == RETURN then
	 repeat
	    local frame = M.stack[M.level]
	    local tail = frame[2]
	    if tail then
	       M.extra = M.extra - 1
	    end

	    local unwind = M.ids[frame[1]]
	    unwind.open = unwind.open - 1
	    unwind.time = unwind.time + clock

	    M.stack[M.level] = nil
	    M.level = M.level - 1
	 until not tail
      end

   end
end

local function start(go)
   if go then
      M.stack = {}
      M.level = 1
      M.extra = 0
      M.depth = find_stack_depth()
      M.stack[M.level] = {start, false}
      M.time = M.time - os.clock()

      debug.sethook(hook, "cr")
   end
end

local function stop()
   M.time = M.time + os.clock()
   debug.sethook()
end

local function report()
   print(string.rep("=", 40))

   local data = {}
   for _, id in pairs(M.ids) do
      table.insert(data, id)
   end

   table.sort(data, function (x, y) return x.time > y.time end)

   for _, id in ipairs(data) do
      if id.open == 0 and id.calls > 1 then
	 local pct = id.time / M.time
	 print(id.name .. "," .. id.calls .. "," .. id.time .. "," .. pct)
      end
   end
end

M.ids = {}
M.time = 0

M.start = start
M.stop = stop
M.report = report

return M
