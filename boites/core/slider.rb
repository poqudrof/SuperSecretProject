def output 
  "value"
end

def input
	"min,max"
end

def create
  @data = {}
  @my_slider = @cp5.addSlider("slider")
    .setLabel("")
    .setSize(80, 10)

  @cp5.update

  value = slider_value
  @data
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
  puts "apply in slider ?!"
end	
