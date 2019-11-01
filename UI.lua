---------------------------------
-- SIMPLE UI LIBRARY
---------------------------------

local UI = { scene = {} }

local c = 
   { background = 
      { normal = { 1,1,1 } 
      , hover = { 102/255, 173/255, 87/255 }
      , active = { 51/255, 51/255, 51/255 }
      } 
   , text = 
      { normal = { 153/255, 153/255, 153/255 }
      , hover = { 1,1,1 }
      , active = { 1,1,1 }
      }
   , border =
      { 217/255, 217/255, 217/255 }
   }

function color(what, action)
   love.graphics.setColor(c[what][action])
end

-- everything should be set according to the grid
local grid_size = 5
local gap = 5
local margin = 10
local smargin = 4 
local radius = 10
local corner = 5
local font = love.graphics.getFont()

function round_to_grid(value)
   return math.ceil(value / grid_size) * grid_size
end

function UI.label(text)
   return { 
      type = "label", 
      text = function () return text[1] end,
   }
end

function draw_label(e, x, y)
   width = font:getWidth(e.text()) + 2 * margin
   height = font:getHeight()
   color("text", "normal") 
   love.graphics.printf(e.text(), x, y, width, "left")
   return width, height
end

function UI.button(text, fun) 
   return { 
      type = "button",
      text = function () return text end, 
      on_click = fun,
      state = "normal",
   }
end

function draw_button(e, x, y)
   width, height = drawFrame(x, y, margin, e.text(), 
      c.background[e.state], c.text[e.state])
   return width, height
end

function UI.slider(min, max, value) 
   return { 
      type = "slider",
      value = function () return value[1] end,
      min = min,
      max = max,
      width = 200,
      state = "normal",
   }
end

function draw_slider(e, x, y)
   local percent = (e.value() - e.min) / (e.max - e.min) 
   local circle = { 
      x = x + e.width * percent - radius, 
      y = y + 2.5 * margin, 
      width = 2 * radius, 
      height = 2 * radius, 
      xc = x + e.width * percent, 
      yc = y + margin * 3.5,
   }
   if percent > 0.1 then
      drawFrame(
         x, y, smargin, e.min, c.background["normal"], c.text["normal"])
   end
   if percent < 0.9 then
      drawFrame(x + e.width - font:getWidth(e.max) - 2 * smargin,
         y, smargin, e.max, c.background["normal"], c.text["normal"])
   end

   drawFrame(x + e.width * percent - font:getWidth(e.value()) / 2,
      y, smargin, e.value(), c.background["hover"], c.text["hover"])
   color("background", "hover") 
   love.graphics.rectangle("fill", x, y + 3 * margin, e.width * percent,
      margin, corner, corner)
   love.graphics.setColor(c.border) 
   love.graphics.rectangle("line", x, y + 3 * margin, e.width,
      margin, corner, corner)
   local space = (e.width - 2 * margin) / 5
   local spaceval = (e.max - e.min) / 5
   for i = 0, 5 do
      love.graphics.setColor(c.border) 
      love.graphics.line(x + margin + i * space, y + 4 * margin, 
         x + margin + i * space, y + 5 * margin)
      love.graphics.setColor(c.text["normal"]) 
      local cur = e.min + i * spaceval
      love.graphics.print(e.min + i * spaceval, 
         x + margin + i * space - font:getWidth(cur) / 2, y + 6 * margin)
   end

   love.graphics.setColor(c.background[e.state]) 
   love.graphics.circle("fill", circle.xc, circle.yc, radius)
   love.graphics.setColor(c.border) 
   love.graphics.circle("line", circle.xc, circle.yc, radius)
   width = e.width
   height = 8 * margin
   return width, height
end

function UI.horizontal(content) 
   content.type = "horizontal"
   return content 
end

function UI.draw_new(scene)
   local r,g,b,a = love.graphics.getColor()
   local cursor_x = 0
   local cursor_y = 0
   local height
   for _, e in ipairs(scene) do
      _, height = UI.draw_element(e, cursor_x, cursor_y)
      cursor_y = cursor_y + height
   end
   love.graphics.setColor(r,g,b,a)
end

function UI.draw_element(e, x, y)
   local width, height = 0, 0
   if e.type == "label" then
      width, height = draw_label(e, x, y)
   elseif e.type == "button" then
      width, height = draw_button(e, x, y)
   elseif e.type == "slider" then
      width, height = draw_slider(e, x, y)
   elseif e.type == "horizontal" then
      local max_height = 0
      local old_x = x
      for _, e_inner in ipairs(e) do
         width, height = UI.draw_element(e_inner, x, y)
         max_height = math.max(max_height, height)
         x = x + round_to_grid(width)
      end
      width = x - old_x
      height = max_height
   end
   return round_to_grid(width), round_to_grid(height)
end

function UI:mousePressed ( position )
   self.pressed = {}
   for _,b in ipairs( self.scene ) do
      if b.type == "button" then
         if b.onClick and pointInAABB( position, b ) then
            b.state = "active"
            table.insert( self.pressed, b )
         end
      elseif b.type == "slider" and b.state == "hover" then
         b.state = "active"
         table.insert( self.pressed, b )
      end
   end
end

function UI:mouseReleased ( position )
   for _,b in ipairs( self.pressed ) do
      if b.type == "slider" then
         b.state = "normal"
      elseif pointInAABB( position, b ) then
         b.onClick()
         b.state = "hover"
      end
   end
end


function UI:mouseMoved ( position )
   for _,b in ipairs( self.scene ) do
      if b.type == "button" then
         if b.state ~= "active" then
            if pointInAABB( position, b ) then
               b.state = "hover"
            else
               b.state = "normal"
            end
         end
      elseif b.type == "slider" then
         local percent = 
            clamp( 0, b.width, position.x - b.x ) / b.width
         if b.state == "active" then
            if pointInAABB( position, b ) then
               b.value[1] = percent * (b.max - b.min) + b.min
            end
         else
            if pointInAABB( position, b.circle() ) then
               b.state = "hover"
            else 
               b.state = "normal"
            end
         end
      end
   end
end

function pointInAABB ( point, box )
   return 
      point.x >= box.x and 
      point.x <= box.x + box.width and
      point.y >= box.y and 
      point.y <= box.y + box.height
end

function clamp ( min, max, value )
   if value < min then return min
   elseif value > max then return max end
   return value
end

function drawFrame ( x, y, margin, text, cback, ctext )
   love.graphics.setColor( cback )
   love.graphics.rectangle( "fill"
      , x, y
      , font:getWidth( text ) + 2 * margin
      , font:getHeight() + 2 * margin
      , corner, corner 
   )
   love.graphics.setColor( c.border )
   love.graphics.rectangle( "line"
      , x, y
      , font:getWidth( text ) + 2 * margin
      , font:getHeight() + 2 * margin
      , corner, corner 
   )
   love.graphics.setColor( ctext )
   love.graphics.print( text, x + margin, y + margin )
   return font:getWidth(text) + 2 * margin, font:getHeight() + 2 * margin
end

return UI
