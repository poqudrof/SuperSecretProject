
module MSSP

  class Link
    attr_reader :in_boite, :out_boite

    def initialize(begin_element, end_element)
      @out_boite = begin_element
      @in_boite = end_element
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

      dist = a.dist(b) + b.dist(c) 
      dist_a_c = a.dist(c)

      return (dist <= dist_a_c + 2 and dist >= dist_a_c - 2)
    end

    def delete
      puts " deleting " + self.to_s
      # @out_boite.remove_input @in_boite
      # @in_boite.remove_output @out_boite

      @in_boite.remove_input @out_boite
      @out_boite.remove_output @in_boite
    end

  end
end
