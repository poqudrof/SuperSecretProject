require 'jruby/core_ext'

module MSSP

  include Processing::Proxy

  class PopUp < Processing::PApplet

    def initialize()
      super
      Processing::PApplet.runSketch( [self.getClass.getName], self)
    end

    def settings
      size 200, 200
    end

    def setup
      puts "Setup !"
    end

    def draw
      background 200
      # puts "draw!"
    end

  end
end
