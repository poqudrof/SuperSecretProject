def input
  "graphics,x,y"
end

def update ; bang ; end

def create
  x = 150
  y = 100
  graphics = @room.getGraphics
end

def apply
  graphics.rect x, y, 150, 150
## was...
#..  @data["graphics"].rect " @data["x"], @data["y"], 150, 150
end
