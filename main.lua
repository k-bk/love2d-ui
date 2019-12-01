local UI = require "UI"

function love.load()

   love.graphics.setBackgroundColor( 1,1,1 )
   big_font = love.graphics.newFont(24)

   -- Set up variables 
   explosives = {15}
   weapon = {}
   boom = "Not loaded"
   name = { "Karol" }

   -- Set up functions for buttons
   function loadCannon () 
      boom = "Loaded" 
   end
   function setFire ()
      if boom == "Loaded" then 
         boom = "BOOM!" 
      end
   end

end

function love.draw()
   UI.draw { x = 30, y = 30,
      UI.label { "Cannon simulator" },
      { UI.label { "Name: " }, UI.inputbox { name }, },
      UI.label { "  - Select amount of explosives:" },
      UI.slider { explosives, range = {0, 100} },
      { 
         UI.button { "Load explosives", on_click = loadCannon },
         UI.button { "Set fire", on_click = setFire },
      },
      UI.label { boom },
      UI.label { "  - Explosives used: "..explosives[1] },
      {
         UI.label { "Best offer -->", font = big_font }, 
         { 
            UI.button { "Get now!", on_click = function () end }, 
            UI.button { "Remind later!", on_click = function () end },
         },
         UI.label { "<-- Best offer", font = big_font },
      },
      UI.label { "Whatever, " },
      UI.label { "  I am done. " },
   }
end

-- Some boilerplate necessary to make ui interactive 

function love.mousepressed(x, y, button)
   local input = { x = x, y = y }
   if button == 1 then
      input = UI.mousepressed(input)
   end
end

function love.mousereleased(x, y, button)
   local input = { x = x, y = y }
   if button == 1 then
      input = UI.mousereleased(input)
   end
end

function love.mousemoved(x, y)
   local input = { x = x, y = y }
   UI.mousemoved(input)
end

function love.textinput(t)
   UI.textinput(t)
end

function love.keypressed(key)
   UI.keypressed(key)
end
