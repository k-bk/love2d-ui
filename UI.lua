---------------------------------
-- SIMPLE UI LIBRARY
---------------------------------

local UI = { 
   pressed = false,
   position = { x=0, y=0 },
   click = { x=0, y=0 },
}

local c = 
   { background = 
      { normal = { 1,1,1 } 
      , hover = { 102/255, 173/255, 87/255 }
      , pressed = { 51/255, 51/255, 51/255 }
      , released = { 51/255, 51/255, 51/255 }
      } 
   , text = 
      { normal = { 153/255, 153/255, 153/255 }
      , hover = { 1,1,1 }
      , pressed = { 1,1,1 }
      , released = { 1,1,1 }
      }
   , border =
      { 217/255, 217/255, 217/255 }
   }

local color = love.graphics.setColor

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

function UI.label(text, align)
   return { 
      type = "label", 
      text = function () return text[1] end,
   }
end

function draw_label(e, x, y)
   local width = font:getWidth(e.text()) + 2 * margin
   local height = font:getHeight()
   color(c.text.normal) 
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
   local width, height = drawFrame(x, y, margin, e.text(), e.state)
   e.state = get_state(rectangle(x, y, width, height), pointInAABB)
   if e.state == "released" then
      UI.released = false
      e.on_click()
   end
   width, height = drawFrame(x, y, margin, e.text(), e.state)
   return width, height
end

function UI.slider(min, max, value) 
   return { 
      type = "slider",
      value = function () return value[1] end,
      set_value = function (val) value[1] = val end,
      min = min,
      max = max,
      width = 200,
      state = "normal",
   }
end

function draw_slider(e, x, y)
   local old_y = y
   local percent = (e.value() - e.min) / (e.max - e.min) 
   local circle = { 
      x = x + margin + e.width * percent, 
      y = y + margin * 3.5, 
      radius = radius,
   }

   local width = e.width + 2 * margin
   local height = 7 * margin

   local state = get_state(rectangle(x, y, width, height), pointInAABB)
   if state == "pressed" then
      local new_percent = (UI.position.x - x - margin) / e.width
      new_percent = clamp(0, 1, new_percent)
      e.set_value(new_percent * (e.max - e.min) + e.min)
   end

   -- draw labels with minimum and maximum
   if percent > 0.05 then
      drawFrame(x, y, smargin, e.min, "normal", "left")
   end
   if percent < 0.95 then
      drawFrame(x + e.width + 2*margin, y, smargin, e.max, "normal", "right")
   end

   drawFrame(circle.x, y, smargin, e.value(), "hover", "center")
   color(c.background.hover)

   y = y + 3 * margin
   love.graphics.rectangle("fill", x, y, margin + e.width * percent,
      margin, corner, corner)
   color(c.border) 
   love.graphics.rectangle("line", x, y, width,
      margin, corner, corner)

   local space = e.width / 5
   local spaceval = (e.max - e.min) / 5
   local val = e.min
   y = y + 2 * margin 
   for offset = margin, e.width + margin, space do
      color(c.border) 
      love.graphics.line(x + offset, y - margin, x + offset, y)
      color(c.text.normal) 
      love.graphics.printf(("%g"):format(val), x + offset - 50, y, 100, "center")
      val = val + spaceval
   end

   color(c.background[get_state(circle, pointInCircle)])
   love.graphics.circle("fill", circle.x, circle.y, radius)
   color(c.border) 
   love.graphics.circle("line", circle.x, circle.y, radius)

   return width, height 
end

function UI.horizontal(content) 
   content.type = "horizontal"
   return content 
end

function UI.draw(scene)
   local r,g,b,a = love.graphics.getColor()
   local cursor_x = scene.x or 0
   local cursor_y = scene.y or 0
   local height
   UI.draw_element(scene, cursor_x, cursor_y, true)
   color(r,g,b,a)
end

function UI.draw_element(e, x, y, flow_down)
   local width, height
   if e.type == "label" then
      width, height = draw_label(e, x, y)
   elseif e.type == "button" then
      width, height = draw_button(e, x, y)
   elseif e.type == "slider" then
      width, height = draw_slider(e, x, y)
   else
      -- change flow of the UI
      local max_x, max_y = 0,0
      for _, e_inner in ipairs(e) do
         width, height = 
            UI.draw_element(e_inner, x, y, not flow_down)
         if flow_down then
            max_x = math.max(max_x, width)
            y = y + round_to_grid(height) + grid_size
         else
            max_y = math.max(max_y, height)
            x = x + round_to_grid(width) + grid_size
         end
      end
      width, height = max_x, max_y
   end
   return round_to_grid(width), round_to_grid(height)
end

function UI.mousepressed(position)
   UI.pressed = true
   UI.position = position
   UI.click = position
end

function UI.mousereleased(position)
   UI.pressed = false
   UI.released = true
end

function UI.mousemoved(position)
   UI.position = position
end

function rectangle(x, y, width, height)
   return { x=x, y=y, width=width, height=height }
end

function get_state(e, in_shape)
   if in_shape(UI.position, e) then
      if UI.pressed then
         if in_shape(UI.click, e) then
            return "pressed"
         else
            return "normal"
         end
      elseif UI.released and in_shape(UI.click, e) then
         return "released"
      else
         return "hover"
      end
   end
   return "normal"
end

function pointInAABB(point, box)
   return point.x >= box.x 
      and point.x <= box.x + box.width
      and point.y >= box.y
      and point.y <= box.y + box.height
end

function pointInCircle(point, circle)
   return (point.x - circle.x)^2 + (point.y - circle.y)^2 <= circle.radius^2
end

function clamp ( min, max, value )
   if value < min then return min
   elseif value > max then return max end
   return value
end

function drawFrame (x, y, margin, text, state, align)
   local align = align or "left"
   local text_width = font:getWidth(text)
   local frame_width = text_width + 2*margin
   local frame_height = font:getHeight(text) + 2*margin
   if align == "right" then
      x = x - frame_width
   elseif align == "center" then
      x = x - frame_width / 2
   end

   color(c.background[state])
   love.graphics.rectangle( 
      "fill", x, y, frame_width, frame_height, corner, corner)
   color(c.border)
   love.graphics.rectangle( 
      "line", x, y, frame_width, frame_height, corner, corner)
   color(c.text[state])
   love.graphics.print(text, x + margin, y + margin)
   return frame_width, frame_height 
end

return UI
