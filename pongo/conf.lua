local C = require("constants")

function love.conf(t)
   t.version = "0.9.0"                -- The LÖVE version this game was made for (string)

   t.window.title = "Pongo"           -- The window title (string)
   t.window.icon = nil                -- Filepath to an image to use as the window's icon (string)
   t.window.width = C.WIDTH           -- The window width (number)
   t.window.height = C.HEIGHT         -- The window height (number)

   t.modules.audio = false            -- Enable the audio module (boolean)
   t.modules.mouse = false            -- Enable the mouse module (boolean)
   t.modules.physics = false          -- Enable the physics module (boolean)
   t.modules.sound = false            -- Enable the sound module (boolean)
end
