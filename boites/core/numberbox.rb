def output
  "value"
end

def input
  "min,max,multiplier"
end

def create
  min = 0
  max = 500
  multiplier = 1
  value = @internal_data if @internal_data != nil

  if room_gui_loaded?
    @numberbox = @skatolo.addNumberbox("numberbox")
                   .setLabel("")
    @skatolo.update
  end
end

def draw g
  if @numberbox != nil and room_gui_loaded?
    @numberbox.setRange(min , max)
    @numberbox.setMultiplier(multiplier)
    @numberbox.setPosition(@location.x, @location.y - 30)
    value = numberbox_value
  end
end

def apply
  value = numberbox_value
end
