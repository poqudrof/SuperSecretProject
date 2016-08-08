require 'yaml'

module MSSP
  class Engine
    attr_reader :links, :boites

    def initialize
      @boites = []
      @links = []
    end

    def run
      @boites.each { |boite| boite.update_global }
    end

    def test

    end

  end
end
