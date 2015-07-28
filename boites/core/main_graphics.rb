def create 
  @data = {}
  @data["graphics"] =@applet.g
  @data["toto"] = "Toto value"
  @data
end

def output
  "graphics,toto"
end

