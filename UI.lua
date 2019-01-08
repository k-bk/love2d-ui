---------------------------------
-- SIMPLE UI LIBRARY
---------------------------------

local UI = 
    { scene = {}
    }

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
local gap = 5
local margin = 10
local smargin = 4 
local radius = 10
local corner = 5
local font = love.graphics.getFont()

function UI:addScene ( x, y )
    self.x = x
    self.y = y
    self.scene = {}
end

function UI:vertical ( e, ... )
    e = e()
    table.insert( self.scene, e )
    self.y = self.y + lastGap 
    if ... then
        UI:vertical (...)
    end
end

function UI:horizontal ( e, ... )
    e = e()
    table.insert( self.scene, e )
    self.x = self.x + e.width + gap
    if ... then
        UI:horizontal (...)
    end
    self.x = self.x - e.width - gap
end

function UI:addButton ( text, fun ) return function ()
    local b = 
        { type = "button"
        , x = self.x, y = self.y
        , text = text, onClick = fun
        , state = "normal"
        , width = font:getWidth( text ) + 2 * margin
        , height = font:getHeight() + 2 * margin
        }
    lastGap = b.height + gap
    return b 
end
end

function UI:addSlider ( min, max, value ) return function()
    local s =
        { type = "slider"
        , x = self.x, y = self.y
        , value = value 
        , min = min
        , max = max
        , width = 200
        , height = font:getHeight() + 5 * margin
        , state = "normal"
        }
    s.percent = 
        function () 
            return (s.value[1] - s.min) / (s.max - s.min) 
        end
    s.circle = function () 
        return
            { x = s.x + s.width * s.percent() - radius
            , y = s.y + 2.5 * margin
            , width = 2 * radius
            , height = 2 * radius
            , xc = s.x + s.width * s.percent()
            , yc = s.y + margin * 3.5 
            }
    end
    lastGap = s.height + gap
    return s
end
end

function UI:addLabel ( text ) return function()
    local t = 
        { type = "text"
        , x = self.x, y = self.y + gap
        , text = function () return text[1] end
        , width = font:getWidth( text[1] ) + 2 * margin
        , height = font:getHeight() + 2 * margin
        }
    lastGap = t.height + gap
    return t
end
end

function UI:addParagraph ( lines ) return function()
    self.y = self.y + gap
    for i = 1,#lines do
        local t = 
            { type = "text"
            , x = self.x, y = self.y
            , text = function () return lines[i] end 
            , width = font:getWidth( lines[i] ) +  margin
            , height = font:getHeight() +  margin
            }
        self.y = self.y + t.height
        table.insert( self.scene, t )
    end
    lastGap = gap
    return t
end
end

function UI:draw ()
    local r,g,b,a = love.graphics.getColor()
    for i,b in ipairs( self.scene ) do
        if b.type == "button" then
            drawFrame( b.x, b.y, margin, b.text
                , c.background[b.state], c.text[b.state]
            )
        elseif b.type == "text" then
            love.graphics.setColor( c.text.normal ) 
            love.graphics.printf( b.text()
                , b.x, b.y + margin
                , b.width, "left"
                )
        elseif b.type == "slider" then
            local circle = b.circle() 
            local percent = b.percent()
            if percent > 0.1 then
                drawFrame( b.x, b.y, smargin, b.min
                    , c.background["normal"], c.text["normal"]
                )
            end
            if percent < 0.9 then
                drawFrame( 
                    b.x + b.width 
                        - font:getWidth( b.max ) 
                        - 2 * smargin
                    , b.y, smargin, b.max
                    , c.background["normal"], c.text["normal"]
                )
            end
            drawFrame( 
                b.x + b.width * percent 
                    - font:getWidth( b.value[1] ) / 2
                , b.y, smargin, b.value[1]
                , c.background["hover"], c.text["hover"]
            )
            love.graphics.setColor( c.background["hover"] ) 
            love.graphics.rectangle( "fill"
                , b.x, b.y + 3 * margin
                , b.width * percent
                , margin
                , corner, corner 
                )
            love.graphics.setColor( c.border ) 
            love.graphics.rectangle( "line"
                , b.x, b.y + 3 * margin
                , b.width
                , margin
                , corner, corner 
                )
            local space = ( b.width - 2 * margin ) / 5
            local spaceval = ( b.max - b.min ) / 5
            for i = 0, 5 do
                love.graphics.setColor( c.border ) 
                love.graphics.line( 
                      b.x + margin + i * space
                    , b.y + 4 * margin
                    , b.x + margin + i * space
                    , b.y + 5 * margin
                    )
                love.graphics.setColor( c.text["normal"] ) 
                local cur = b.min + i * spaceval
                love.graphics.print( b.min + i * spaceval
                    , b.x + margin + i * space - font:getWidth(cur) / 2
                    , b.y + 6 * margin
                    )
                end

            love.graphics.setColor( c.background[b.state] ) 
            love.graphics.circle( "fill"
                , circle.xc, circle.yc, radius )
            love.graphics.setColor( c.border ) 
            love.graphics.circle( "line"
                , circle.xc, circle.yc, radius )
        end
    end
    love.graphics.setColor( r,g,b,a )
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
end

return UI
