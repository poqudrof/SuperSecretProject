def output
  "graphics"
end

def create
  @popup = MSSP::PopUp.new
  graphics = @popup.g
  @popup.boite = self
end

def apply
  bang_on_outputs
end

def delete
  @popup.getSurface.setVisible false
end
