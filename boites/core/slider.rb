def output 
  "value"
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
  @my_slider.setPosition(@location.x , @location.y) if @my_slider != nil
  @data["value"] = slider_value if has_data?
end


def apply 
  value = slider_value
  @data	
end	
