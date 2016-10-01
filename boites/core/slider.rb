def output
  "value"
end

def input
  "min,max"
end

def create
  min = 0
  max = 100
  value = @internal_data if @internal_data != nil

  @my_slider = @skatolo.addSlider("slider")
    .setLabel("")
    .setSize(80, 10)
  @skatolo.update
end

def draw g
  if @my_slider != nil
    @my_slider.setRange(min , max)
    @my_slider.setPosition(@location.x  + 30, @location.y - 10)
    value = slider_value
  end
end

def apply
  value = slider_value
end
