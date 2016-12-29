def output
  "x"
end

def create
  x = 0
end

def apply
  # nothing to see here.
  # x = Math.sin $app.millis / 1000.0
end

def x
  if defined? $app
    Math.sin $app.millis / 1000.0
  else
    Math.sin @k / 1000.0
    @k = k+1
  end
end
