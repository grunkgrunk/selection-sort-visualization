local class = require 'util.middleclass'
local Timer = require 'util.timer'
local round = function(n) return math.floor(n+0.5) end

local Box = class('Box')

local colors = {
  min = 0,
  normal = 16,
}

function Box:initialize(number, s, shack)
  self.number = number
  self.s = s or 16
  self.shack = shack

  self.x = 0
  self.y = 0
  self.issmallest = false
  self.timer = Timer.new()
  self.color = colors.normal

end

function Box:drawConnection()
  color(0)
  love.graphics.rectangle("fill", self.x+self.s/2-2,self.s/2-2, 3, 3)
  love.graphics.line(self.x+self.s/2, self.y+self.s/2, self.x+self.s/2, self.s/2)
end

function Box:draw()
  color(self.number)
  love.graphics.rectangle("fill", round(self.x),round(self.y),self.s,self.s)

  color(self.color)
  local strnum = tostring(self.number)
  love.graphics.print(
    self.number,
    round(self.x+self.s/2-2*#strnum),
    round(self.y+self.s/2-2)
  )

  if self.issmallest then self:drawOutline(colors.min) end
end

function Box:drawOutline(c)
  color(c)
  love.graphics.rectangle("line", round(self.x)+1,round(self.y)+1, self.s-1,  self.s-1)
end

function Box:update(dt)
  if self.number == 0 then self.number = 1 end
  self.timer:update(dt)
end

function Box:move(x,y, t, fn)
  self.timer:tween(t or 0.4, self, {x=x or self.x, y=y or self.y}, 'in-out-quad', fn)
end

function Box:tweenFn(tbl, t)
  return function(fn)
    self.timer:tween(t or 0.2, self, tbl, 'linear', fn)
  end
end

function Box:compare(with)
  local r = self.n > with.n
  return r
end

function Box:swap(x, sgn, wait)
  local to = self:tweenFn({x=x}, 0.2)
  local down = self:tweenFn({y=0}, 0.2)

  to()
  wait(0.5)
  down()
  wait(0.1)
  self.shack:shake(10)
  wait(0.2)
end

return Box
