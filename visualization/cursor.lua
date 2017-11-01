local class = require 'util.middleclass'
local round = function(n) return math.floor(n+0.5) end

local Cursor = class('Cursor')

function Cursor:initialize(boxes, shack)
  self.boxes = boxes
  self.max = #boxes
  self.shack = shack

  self.s = boxes[1].s
  self.i = 0
  self.box = boxes[self.i + 1]
  self.color = 4
  self.x, self.y = 0,0
end

function Cursor:update(dt)
  self.x,self.y = self.box.x,self.box.y
end

function Cursor:move(dir)
  target = self.i + dir
  if self.i + dir > self.max-1 then
    target = 0
  elseif self.i + dir < 0 then
    target = self.max-1
  end
  self.i = target
  self.box = self.boxes[target+1]
end

function Cursor:bump(dir)
  self.box.number = self.box.number + dir

  if self.box.number == 0 then
    self.box.number = 14
  end

  if self.box.number == 15 then
    self.box.number = 1
  end

  self.shack:shake(10)
end

function Cursor:draw()
  color(self.box.number)
  local sx,sy = self.s+1, self.s+1
  love.graphics.rectangle('line', round(self.box.x),round(self.box.y), sx,sy)
end

return Cursor
