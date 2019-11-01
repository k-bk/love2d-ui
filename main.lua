local UI = require "UI"

function love.load()

   love.graphics.setBackgroundColor( 1, 1, 1 )

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

function love.draw()
   UI.draw {
      UI.label { "Cannon simulator:" },
      UI.label { "  Select amount of explosives" },
      UI.label { "Do whatever you want" },
      UI.slider( 0, 100, explosives ),
      UI.horizontal { 
         UI.button( "Load explosives", loadCannon ),
         UI.button( "Set fire", setFire ),
      },
      UI.label( boom ),
   }
end

-- Some boilerplate necessary to make the sliders and buttons work

function love.mousepressed ( x, y, button )
    if button == 1 then
        UI:mousePressed {x = x, y = y}
    end
end

function love.mousereleased ( x, y, button )
    if button == 1 then
        UI:mouseReleased {x = x, y = y}
    end
end

function love.mousemoved ( x, y )
    UI:mouseMoved {x = x, y = y}
end
