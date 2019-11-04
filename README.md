# love2d-ui
Simple UI library for LÖVE framework

## Run the demo
Demo code is inside `main.lua` file.

**Linux**
Type `make` inside cloned repo to test the capabilities of the library.

## Example
```lua
function love.load ()
   -- Set up variables used as labels (note the curly brackets)
   explosives = {15}
   boom = {"Not loaded"}

   -- Set up functions for buttons
   function loadCannon () 
      boom[1] = "Loaded" 
   end
   function setFire ()
      -- This ugly [1] access is necessary to make indirect reference
      if boom[1] == "Loaded" then 
         boom[1] = "BOOM!" 
      end
   end
end

function love.draw ()
   UI = require "UI"
   UI.draw_new {
      UI.label { "Select amount of explosives" },
      UI.slider( 0, 100, explosives ),
      UI.horizontal {  
         UI.button( "Load explosives", loadCannon ), 
         UI.button( "Set fire", setFire )
      },
      UI.label( boom ),
   }
end
```
![Example of UI](example.png)

*Written in [Lua](https://www.lua.org/) using awesome [love2d](https://love2d.org/) framework.*
