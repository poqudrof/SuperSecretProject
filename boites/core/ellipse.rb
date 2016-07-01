def input
  "graphics,x,y"
end

def create
  x = 150
  y = 100
  graphics = @room.getGraphics
end

def apply
  graphics.ellipse x, y, 150, 150
end
