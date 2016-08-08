module MSSP

  class Link
    attr_reader :in_boite, :out_boite, :input_bang
    attr_accessor :bang

    def initialize(begin_element, end_element, input_bang)
      @out_boite = begin_element
      @in_boite = end_element

      @in_boite_index = input_bang.index

      @input_bang = input_bang
      @bang = false
    end

    def draw(graphics)

      graphics.fill(245,27,27) if @bang

      input_offset = @in_boite_index * @in_boite.input_space
      input = input_location
      output = output_location

      graphics.line(input.x, input.y,
                    output.x, output.y)
    end

    def input_location
      input_offset = @in_boite_index * @in_boite.input_space
      Vec2D.new(@in_boite.location.x + input_offset,
                @in_boite.location.y)
    end

    def output_location
      Vec2D.new(@out_boite.location.x + 5,
                @out_boite.location.y + 20 + 5)
    end

    def check_click(x,y)

      b = Vec2D.new(x,y)
      a = input_location
      c = output_location

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
      @in_boite.remove_input self, @out_boite
      @out_boite.remove_output self, @in_boite
    end

  end
end
