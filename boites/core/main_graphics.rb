def create 
  @data = create_data(@applet.g, "graphics")
  @data["toto"] = "Toto value"
  @data
end

def output
  "graphics,toto"
end

