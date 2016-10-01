is_a_bang!

def create

  @my_toggle = @skatolo.addToggle("toggle")
                 .setLabel("")
                 .setSize(80, 10)
  @my_toggle.setValue @internal_data if @internal_data != nil

  @skatolo.update
end

def draw
  if @my_toggle != nil
    @my_toggle.setPosition(@location.x  + 30, @location.y - 10)
  end
end

def apply
  bang_on_outputs if toggle_value == 1
  @internal_data = toggle_value
end
