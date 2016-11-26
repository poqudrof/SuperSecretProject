def input
  "dummy"
end

def output
  "x"
end

def create
  x = 0
  dummy = "dummy"
end

def apply
  # nothing to see here.
  # x = Math.sin $app.millis / 1000.0
end

def x
  Math.sin $app.millis / 1000.0
end
