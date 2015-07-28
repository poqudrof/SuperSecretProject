def output
	"x"
end

def create
  @data = {}
  x = 0
end

def update
  x = Math.sin $app.millis / 1000.0
end	
