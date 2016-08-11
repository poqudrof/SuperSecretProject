module MSSP


  class InputBang
    include MSSP

    attr_reader :index, :name
    attr_accessor :controller

    attr_reader :links

    def initialize boite, name, index
      @boite, @name, @index = boite.id, name, index
      @sources = []
      @links = []
    end

    def remove_link link
      @links.delete link
    end

    def remove_source boite
      @sources.delete boite
      puts @sources.to_s
      puts "removed ?" + boite.id.to_s
    end

    def boite ; from_engine @boite ; end
    def source ; from_engine @source ; end
    def sources ; @sources.map {|s| from_engine s} ; end
    def add_source source ; @sources << source ; end

#     def encode_with encoder
#       # encoder['boite'] = @boite
#       encoder['name'] = @name
#       encoder['index'] = @index
#       encoder['links'] = @links ## to regenerate (GUI)
#       encoder['sources'] = @sources
#       encoder['source'] = @source unless not is_filled?

# #       encoder['boite'] = @boite.id
# #       encoder['name'] = @name
# #       encoder['index'] = @index
# #       encoder['sources'] = @sources.map {|boite| boite.id }
# #       encoder['source'] = @source.id unless not is_filled?

#     end

    # def init_with encoder
    #   @source =

    def fill_with source ; @source = source.id ; end
    def is_filled? ; @source != nil ; end
    def unfill ; @source = nil ; sources = []; links = []; end

    def controller_name ; "input_bang_" + @name ; end
    def self.controller_name(name) ; "input_bang_" + name ; end

  end

end
