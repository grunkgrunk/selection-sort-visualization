-- monkeypatching

--love.graphics.ImageData
shack=require'util.shack'
lume=require'util.lume'
Timer=require'util.timer'
tween=require'util.tween'
Vector=require'util.vector'

local Box = require 'box'
local Cursor = require 'cursor'
--middleclass=require'util.class'

love.graphics.setLineStyle "rough"
love.graphics.setDefaultFilter("nearest", "nearest")

scale = 6

love.window.setMode(128 *scale, 128 * scale, {borderless=true})

local rnd, abs, flr = love.math.random, math.abs, math.floor
local mx, my = love.mouse.getX, love.mouse.getY


local screen = love.graphics.newCanvas(128, 128)
local objectScreen = love.graphics.newCanvas(128,128)

local strength = 1000 -- The more circles the stronger the effect.
local sin,cos,tan = math.sin,math.cos,math.tan
t=0

palette = {
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

-- palettes
bg = {15, 10, 9, 4, 2}

function map(x, a,b, c,d)
  return (x-a)/(b-a)*(d-c)+c
end

function color(i)
  -- should use modulo better
  love.graphics.setColor(palette[flr(i) % 16 + 1])
end

function pal(c1, c2)
  local a,b=palette[c1],palette[c2]
  --palette[]
end

function dither(x,y)
  love.graphics.points(x+1,y, x-1,y, x,y+1,  x,y-1)
end

function findi(t,val)
  for i,v in ipairs(t) do
    if v == val then return i end
  end
  return t[#t]
end

function rgbtonum(r,g,b)
  for i,col in ipairs(palette) do
    local r1,g1,b1=col[1],col[2],col[3]
    if r==r1 and g==g1 and b==b1 then return i-1 end
  end
end


function swap(arr, i,j)
  local a,b = arr[i], arr[j]
  arr[i],arr[j] = b,a
end

function stopSort()
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

between=0.5

function love.load()
  local font=love.graphics.newFont('font.ttf', 4)
  love.graphics.setFont(font)
  boxes={}

  for i = 0,10 do
    local b = Box:new(math.random(10), 10)
    b.x = i * (b.s)
    b.y = 64
    b:move(nil, 0)

    boxes[#boxes+1]=b
  end

  cursor = Cursor:new(boxes)

  function nextBox(i)
    return i+1, boxes[i+1]
  end

  function compare(a,b)
    if a==b then return 0 end
    return a < b
  end

  function revert(selected, minbox)
    lume.each(boxes, function(b)
      if b ~= selected and b ~= minbox then
        b.color = Box.colors.normal
        b.issmallest = false
        b:move(b.x, 0, 0.5)
      end
    end)
  end


  sorting = false
  function sortBoxes()
    sorting = true
    sortHandle = Timer.script(function(wait)
      --curri, selected=nextBox(curri)
      local curri=1
      local selected = boxes[curri]
      --selected.color = Box.colors.select
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
          --local c=compare(currn,n)

          if box.number == selected.number then
            --box.color = Box.colors.equal

          end

          if box.number < min.box.number then
            if min.box ~= selected then
              min.box.color = Box.colors.normal
              min.box.issmallest = false
            end
            min.i, min.box = i, box
            --min.box.color = Box.colors.min
            min.box.issmallest = true
          end

          box:move(nil, (currnum - box.number)*box.s/2)
          wait(0.6)
        end

        -- allign everything again
        revert(selected, min.box)

        if min.box ~= selected then
          wait(0.2)
          -- swapping time!
          swap(boxes, curri, min.i)
          --Box.swap(selected, min.box, 1)
          local x1, x2 = min.box.x, selected.x
          selected:move(nil, -16+2)
          min.box:move(nil, 16+2)
          wait(0.3)
          selected:swap(x1, -1, wait)
          min.box:swap(x2, 1, wait)
          --wait(0.5)
        end
        min.box.issmallest = false
        --selected.color = Box.colors.normal
        --wait(0.5)
        curri=curri + 1
        selected=boxes[curri]

        --if not sorting then return false end

      end
    end)
  end
end

function love.update(dt)
  t = t + dt
  shack:update(dt)
  Timer.update(dt)

  lume.each(boxes, function(b) b:update(dt) end)
  if not sorting then
    cursor:update(dt)
  end
end

function love.draw()
--love.graphics.push()

BEGIN_DRAW()

  love.graphics.push()
  local s = boxes[1].s
  local l=#boxes*s
  love.graphics.translate(63-l/2, 64)

  -- draw the line behind
  color(0)
  love.graphics.line(s/2, s/2, l-s/2, s/2)
  lume.each(boxes, function(b) b:drawConnection() end)
  local txt ="PRESS X TO STOP."
  if not sorting then
    txt="PRESS X TO SORT!"
  end
  color(0)
  love.graphics.print(txt, #txt*3/2, -32)

  lume.each(boxes, function(b) b:draw() end)
  cursor:draw()

  love.graphics.pop()

END_DRAW()
end

function BEGIN_DRAW()

  love.graphics.setCanvas(screen)

  local data=screen:newImageData()
  for i = 1, 1000 do
    local x,y=flr(rnd(0,127)),flr(rnd(0,127))
    -- this is stupid

    local col=15
    --if math.random(1000) > 600 then
    --  local r,g,b=data:getPixel(x,y)
    --  local c=rgbtonum(r,g,b)
    --  local newcol = bg[findi(bg, c) + math.random(-1, 1)]
      --if newcol then col = newcol end
    --end
    color(col)
    dither(x, y+1)
    love.graphics.points(x,y)

  end

  love.graphics.setCanvas(screen)
  love.graphics.setColor(255,255,255)
  --love.graphics.clear()

end

function END_DRAW() -- render frame.
  --love.graphics.setCanvas(screen)
  --love.graphics.setColor (255,255,255)

  love.graphics.setCanvas()
  love.graphics.clear()
  love.graphics.setColor (255,255,255)

  shack:apply()
  love.graphics.draw(screen,0,0,0,scale,scale)
  love.graphics.draw(objectScreen,0,0,0,scale,scale)
end

function love.keypressed(key, code, isrepeat)
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
      --Timer.clear()
      --revert()
      stopSort()
      sorting = false

    else
      sortBoxes()
    end
  end

end
