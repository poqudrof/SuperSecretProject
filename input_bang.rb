module MSSP

  class InputBang

    attr_reader :boite, :index, :name
    attr_accessor :controller

    attr_reader :sources
    attr_reader :links

    attr_reader :source

    def initialize boite, name, index
      @boite, @name, @index = boite, name, index
      @sources = []
      @links = []
    end

    def fill_with source ; @source = source ; end
    def is_filled? ; @source != nil ; end
    def unfill ; @source = nil ; end

    def controller_name ; "input_bang_" + @name ; end
    def self.controller_name(name) ; "input_bang_" + name ; end

  end

end
