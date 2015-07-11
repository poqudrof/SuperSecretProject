
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
  end
end
