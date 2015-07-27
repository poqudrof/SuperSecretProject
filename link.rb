
module MSSP

  class Link
    attr_reader :in_boite, :out_boite, :transmitted_values
    attr_accessor :bang
    
    def initialize(begin_element, end_element, end_id)
      @out_boite = begin_element
      @in_boite = end_element
      @transmitted_values = []

      @in_boite_index = end_id
      @bang = false
    end

    def draw(graphics)

      graphics.fill(245,27,27) if @bang

      input_offset = @in_boite_index * @in_boite.input_space

      graphics.line(@in_boite.location.x + input_offset,
                    @in_boite.location.y, 
                    @out_boite.location.x,
                    @out_boite.location.y)

    end

    def check_click(x,y)
      
      b = Vec2D.new(x,y)
      a = @in_boite.location 
      c = @out_boite.location 

      # check distance to the box 
      return false if b.dist(a) < 20 or b.dist(c) < 20

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
