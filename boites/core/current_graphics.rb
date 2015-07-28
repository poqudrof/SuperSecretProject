def create 
  @data["graphics"] = @room.getGraphics
  @data
end

def output
  "graphics"
end

