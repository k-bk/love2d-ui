local UI = require "UI"

function love.load()

   love.graphics.setBackgroundColor( 1,1,1 )

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
      UI.inputbox( name ),
      UI.label { "  - Select amount of explosives:" },
      UI.slider( 0, 100, explosives), -- 'explosives' has to be a table
      { 
         UI.button( "Load explosives", loadCannon ),
         UI.button( "Set fire", setFire ),
      },
      UI.label { boom },
      UI.label { "  - Explosives used: "..explosives[1] },
      {
         UI.label { "Best offer -->" }, 
         { 
            UI.button( "Get now!", function () end ), 
            UI.button( "Remind later!", function () end ) 
         },
         UI.label { "<-- Best offer" },
      },
      UI.label { "Whatever, " },
      UI.label { "  I am done. " },
   }
end

-- Some boilerplate necessary to make ui interactive 

function love.mousepressed(x, y, button)
   local input = v2(x,y)
   if button == 1 then
      input = UI.mousepressed(input)
      input = lab.mousepressed(input)
   end
end

function love.mousereleased(x, y, button)
   local input = v2(x,y)
   if button == 1 then
      input = UI.mousereleased(input)
   end
end

function love.mousemoved(x, y)
   local input = v2(x,y)
   UI.mousemoved(input)
end

function love.textinput(t)
   UI.textinput(t)
end

function love.keypressed(key)
   UI.keypressed(key)
end
