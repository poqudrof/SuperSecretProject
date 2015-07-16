
def input
  "graphics,x,y"
end

def apply data 

  data["graphics"].rect data["x"], data["y"], 150, 150

## to become... 
#..  graphics.rect x, y, 150, 150
  data
end


