def output
  "value"
end

def create
  value = 0
end

def set_value new_value
  value = new_value
end

def draw g
      g.text value.to_s, 0, 15
end
