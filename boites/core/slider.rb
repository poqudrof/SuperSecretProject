def output
  "value"
end

def input
	"min,max"
end

def create
  @my_slider = @skatolo.addSlider("slider")
    .setLabel("")
    .setSize(80, 10)
  @skatolo.update
  value = slider_value
end

def update
  if @my_slider != nil
    @my_slider.setRange(0 , 1000)
    @my_slider.setPosition(@location.x  + 30, @location.y - 10)
    value = slider_value if has_data?
  end
end


def apply
  value = slider_value
end
