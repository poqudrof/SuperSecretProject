module MSSP
  class InputBangBase
    include MSSP

    attr_reader :index, :name
    attr_accessor :controller
    attr_reader :links

    def initialize boite, name, index
      @boite, @name, @index = boite.id, name, index
      @links = []
    end

    def remove_link link
      @links.delete link
    end

    def clear_links
      @links.clear
    end

    def boite ; from_engine @boite ; end

    def controller_name ; "input_bang_" + @name ; end
    def self.controller_name(name) ; "input_bang_" + name ; end
  end
end
