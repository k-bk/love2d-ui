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
   
   UI:addScene(20, 20)
   UI:vertical(
      UI:addLabel {"Cannon simulator:"},
      UI:addLabel {"  Select amount of explosives"},
      UI:addSlider( 0, 100, explosives ),
      UI:addLabel {""}
   )
   UI:horizontal(
      UI:addButton( "Load explosives", loadCannon ), 
      UI:addButton( "Set fire", setFire )
   )
   UI:vertical( 
      UI:addLabel {""},
      UI:addLabel( boom ) 
   )

end

function love.draw()
   UI:draw()
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
