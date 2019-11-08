local UI = require "UI"

function love.load()

   love.graphics.setBackgroundColor( 1, 1, 1 )

   -- Set up variables 
   explosives = {15}
   boom = "Not loaded"

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
      }
   }
end

-- Some boilerplate necessary to make ui interactive 

function love.mousepressed ( x, y, button )
    if button == 1 then
        UI.mousepressed {x = x, y = y}
    end
end

function love.mousereleased ( x, y, button )
    if button == 1 then
        UI.mousereleased {x = x, y = y}
    end
end

function love.mousemoved ( x, y )
    UI.mousemoved {x = x, y = y}
end
