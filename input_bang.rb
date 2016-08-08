module MSSP

  class InputBang
    attr_reader :boite, :index
    attr_reader :source, :name
    attr_reader :sources

    attr_accessor :controller

    def initialize boite, name, index
      @boite, @name, @index = boite, name, index
      @sources = []
    end

    def controller_name ; "input_bang_" + @name ; end
    def fill_with source; @source = source ; end
    def is_filled? ; @source != nil ; end

    def unfill ; @source = nil ; end

    def self.controller_name(name) ; "input_bang_" + name ; end

  end

end
