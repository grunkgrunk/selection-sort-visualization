local class = require 'util.middleclass'
local Timer = require 'util.timer'
local Box = require 'box'
local round = function(n) return math.floor(n+0.5) end

local Cursor = class('Cursor')

function Cursor:initialize(boxes)
  self.boxes = boxes

  self.max = #boxes
  self.s = boxes[1].s
  self.i = 0
  self.box = boxes[self.i + 1]
  self.color = 4
  --self.timer = Timer.new()
  self.x, self.y = 0,0
  self.box.color = Box.colors.highlight
end

function Cursor:update(dt)
  --self.timer:update(dt)
  self.x,self.y = self.box.x,self.box.y

end

function Cursor:move(dir)

  self.box.color = Box.colors.normal

  target = self.i + dir
  if self.i + dir > self.max-1 then
    --self.i = 0
    target = 0
  elseif self.i + dir < 0 then
    --self.i = self.max-1
    target = self.max-1
  end
  self.i = target
  self.box = self.boxes[target+1]

  self.box.color = Box.colors.highlight
  --self.timer:tween(0.1, self, {i = target}, 'in-out-quad',
  --function()
  --  self.i = self.i % self.max
  --  self.box = self.boxes[self.i]

  --end)
  --self.i = self.i + dir
end

function Cursor:bump(dir)
  self.box.number = self.box.number + dir

  if self.box.number == 0 then
    self.box.number = 14
  end

  if self.box.number == 15 then
    self.box.number = 1
  end

  shack:shake(10)
end

function Cursor:draw()
  color(self.box.number)
  --local s = self.s * 1.5

  --love.graphics.rectangle("fill",self.i * self.s, self.s + 2, self.s, self.s/2)
  local sx,sy = self.s+1, self.s+1

  --love.graphics.rectangle("line", self.i*self.s,self.box.y, sx,sy)
  love.graphics.rectangle("line", round(self.box.x),round(self.box.y), sx,sy)
  --color(self.box.color)
  --local strnum = tostring(self.box.number)
  --love.graphics.print(strnum, self.i*self.s-2+sx/2,sy/2-2)
end

return Cursor
