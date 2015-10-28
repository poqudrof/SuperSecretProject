# -*- coding: utf-8 -*-

require 'ruby-processing'
require 'jruby_art'
require 'jruby_art/app'

require 'jruby/core_ext'

# Processing::Runner
# Dir["#{Processing::RP_CONFIG['PROCESSING_ROOT']}/core/library/\*.jar"].each{ |jar| require jar }
# Processing::App::SKETCH_PATH = __FILE__   unless defined? Processing::App::SKETCH_PATH

require './skatolo'
require './boite'
require './room'

class MyApp < Processing::App

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  def settings
    size 800, 800, P3D
  end

  def setup
    @room = Room.new self, 800, 800

  end


  def draw
    background 100
    @room.draw
    image(@room.graphics, 0, 0, 800, 800)
  end

  def mouse_pressed
    @room.mouse_pressed
  end

end


MyApp.new  unless defined? $app
