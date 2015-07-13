
module MSSP

  class Link
    attr_reader :in_boite, :out_boite

    def initialize(begin_element, end_element)
      @in_boite = begin_element
      @out_boite = end_element
    end

    def draw(graphics) 
      graphics.line(@in_boite.location.x, 
                    @in_boite.location.y, 
                    @out_boite.location.x,  
                    @out_boite.location.y)
    end

    def check_click(x,y)
      
      b = Vec2D.new(x,y)
      a = @in_boite.location 
      c = @out_boite.location 

      return a.dist(c) + b.dist(c) == a.dist(b)
    end

    def delete
      @out_boite.remove_input @in_boite
      @in_boite.remove_output @out_boite
    end

  end
end
