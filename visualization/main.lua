
local shack=require'util.shack'
local lume=require'util.lume'
local Timer=require'util.timer'

local Box = require 'box'
local Cursor = require 'cursor'

local rnd, abs, flr = love.math.random, math.abs, math.floor

love.graphics.setLineStyle("rough")
local canvas = love.graphics.newCanvas(128, 128)
canvas:setFilter("nearest","nearest")

local sin,cos,tan = math.sin,math.cos,math.tan

local scale = 6
love.window.setMode(128 *scale, 128 * scale, {borderless=true})

local palette = {
  {0,0,0},
  {29,43,83},
  {126,37,83},
  {0,135,81},
  {171,82,54},
  {95,87,79},
  {194,195,199},
  {255,241,232},
  {255,0,77},
  {255,163,0},
  {255,236,39},
  {0,228,54},
  {41,173,255},
  {131,11,156},
  {255,119,168},
  {255,204,170}
}

function BEGIN_DRAW()
  local function rgbtonum(r,g,b)
    for i,col in ipairs(palette) do
      local r1,g1,b1=col[1],col[2],col[3]
      if r==r1 and g==g1 and b==b1 then return i-1 end
    end
  end

  local function findi(t,val)
    for i,v in ipairs(t) do
      if v == val then return i end
    end
    return t[#t]
  end

  love.graphics.setCanvas(canvas)
  local data = canvas:newImageData()
  for i = 1, 1000 do
    local x,y=rnd(0,127),rnd(0,127)
    local clearcol=15
    -- If we want to do something based on the color at the pixel x,y
    --if math.random(1000) > 600 then
    --  local r,g,b=data:getPixel(x,y)
    --  local c=rgbtonum(r,g,b)
    --  local newcol = bg[findi(bg, c) + math.random(-1, 1)]
      --if newcol then clearcol = newcol end
    --end

    -- the dithering effect
    color(clearcol)
    love.graphics.points(x+1,y, x-1,y, x,y+1,  x,y-1)
  end
end

function END_DRAW()
  love.graphics.setCanvas()
  love.graphics.setColor (255,255,255)
  love.graphics.setBlendMode("alpha", "premultiplied")
  shack:apply()
  love.graphics.draw(canvas,0,0,0,scale,scale)
end

function color(i)
  love.graphics.setColor(palette[flr(i) % 16 + 1])
end

function swap(arr, i,j)
  local a,b = arr[i], arr[j]
  arr[i],arr[j] = b,a
end

function stopsort()
  sorting = false
  Timer.clear()
  Timer.script(function(wait)
    wait(0.2)
    for i = 1,#boxes do
      local b = boxes[i]
      local x = (i-1) * (b.s)
      b.timer:clear()
      b:move(x)
    end
    wait(0.5)
    revert()
    wait(0.5)
  end)
end

function revert(selected, minbox)
  lume.each(boxes, function(b)
    if b ~= selected and b ~= minbox then
      b.issmallest = false
      b:move(b.x, 0, 0.5)
    end
  end)
end

function sortboxes()
  sorting = true
  sortHandle = Timer.script(function(wait)
    local curri=1
    local selected = boxes[curri]
    wait(0.2)

    while true do
      if curri > #boxes-1 then
        sorting = false
        shack:shake(5)
        return false
      end

      selected = boxes[curri]
      cursor.box = selected
      cursor.i = curri-1

      wait(0.2)

      local i = curri
      local currnum= selected.number

      local min = {i=curri, box=selected}

      while true do
        i = i + 1
        local box = boxes[i]

        if i > #boxes then break end

        if box.number < min.box.number then
          if min.box ~= selected then
            min.box.issmallest = false
          end
          min.i, min.box = i, box
          min.box.issmallest = true
        end

        local to = (currnum - box.number)*box.s/2
        local time = 0
        if to ~= 0 then
          time = abs(to)/80
          box:move(nil, to, time)
        end
        wait(time + 0.1)
      end

      -- allign everything again
      revert(selected, min.box)

      if min.box ~= selected then
        wait(0.2)
        -- swapping time!
        swap(boxes, curri, min.i)

        local x1, x2 = min.box.x, selected.x
        selected:move(nil, -16+2)
        min.box:move(nil, 16+2)
        wait(0.3)
        selected:swap(x1, -1, wait)
        min.box:swap(x2, 1, wait)
      end
      min.box.issmallest = false
      curri=curri + 1
      selected=boxes[curri]
    end
  end)
end

function love.load()
  local font=love.graphics.newFont('font.ttf', 4)
  love.graphics.setFont(font)
  boxes={}

  for i = 0,10 do
    local b = Box:new(math.random(1,14), 10, shack)
    b.x = i * (b.s)
    b.y = 64
    b:move(nil, 0, math.random()*0.4+0.1)

    boxes[#boxes+1]=b
  end

  cursor = Cursor:new(boxes, shack)
  sorting = false
end

function love.update(dt)
  shack:update(dt)
  Timer.update(dt)

  lume.each(boxes, function(b) b:update(dt) end)
  if not sorting then
    cursor:update(dt)
  end
end

function love.draw()
BEGIN_DRAW()

  love.graphics.push()
  local s = boxes[1].s
  local l=#boxes*s
  love.graphics.translate(63-l/2, 64)

  -- draw the lines behind the boxes
  color(0)
  love.graphics.line(s/2, s/2, l-s/2, s/2)
  lume.each(boxes, function(b) b:drawConnection() end)

  color(0)
  local txt = sorting and "PRESS X TO STOP." or "PRESS X TO SORT!"
  love.graphics.print(txt, #txt*3/2, -32)

  lume.each(boxes, function(b) b:draw() end)
  cursor:draw()

  love.graphics.pop()

END_DRAW()
end

function love.keypressed(key)
  if key == "escape" then love.event.quit() end

  if not sorting then
    if key == "left" then
      cursor:move(-1)
    end
    if key == "right" then
      cursor:move(1)
    end
    if key == "up" then
      cursor:bump(1)
    end
    if key == "down" then
      cursor:bump(-1)
    end
  end
  if key == "x" then
    if sorting then
      stopsort()
    else
      sortboxes()
    end
  end
end
