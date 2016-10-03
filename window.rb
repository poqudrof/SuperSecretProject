require 'jruby/core_ext'

module MSSP

  include Processing::Proxy

  class PopUp < Processing::PApplet

    attr_accessor :boite

    def initialize()
      super
      Processing::PApplet.runSketch( [self.getClass.getName], self)
    end

    def settings
      size 300, 300
    end

    def setup
      puts "Setup !"
    end

    def draw
      background 40, 40, 180
      # puts "draw!"
      if @boite != nil and $engine.is_ready?
        @boite.bang_on_outputs
      end

    end

  end
end
