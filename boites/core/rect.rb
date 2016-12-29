def input
  "graphics,x,y"
end

is_a_bang!

def create
  x = 150
  y = 100
  graphics = @room.getGraphics if room_gui_loaded?
end

def apply
  graphics.rect x, y, 150, 150
end
