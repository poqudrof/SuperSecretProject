def output
  "value"
end

def create
  set_value 0
end

def set_value new_value
  value = new_value
  @internal_data = value
end

def draw g
      g.text @internal_data.to_s, 0, 15
end
