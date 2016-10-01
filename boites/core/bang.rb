is_a_bang!

def create
  @activated = false
  @my_toggle = @skatolo.addBang("bang_activated")
                 .setLabel("")
                 .setSize(15, 15)
  @skatolo.update
end

def draw g
  if @my_toggle != nil
    @my_toggle.setPosition(@location.x  + 30, @location.y - 10)
  end
end

def bang_activated
  @activated = true
end

def apply
  bang_on_outputs if @activated
  @activated = false
end
