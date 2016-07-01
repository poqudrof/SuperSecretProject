# -*- coding: utf-8 -*-

require 'jruby_art'
require 'jruby_art/app'

require 'jruby/core_ext'

# Processing::Runner
# Dir["#{Processing::RP_CONFIG['PROCESSING_ROOT']}/core/library/\*.jar"].each{ |jar| require jar }
# Processing::App::SKETCH_PATH = __FILE__   unless defined? Processing::App::SKETCH_PATH

require './skatolo'
require './boite'
require './room'
require './window'

class MyApp < Processing::App

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  def settings
    size 800, 800, OPENGL
  end

  def setup
    @room = Room.new self, 800, 800

  end


  def draw
    background 100
    @room.draw
    image(@room.graphics, 0, 0, 800, 800)
  end

  def mouse_pressed(*args)
    @room.mouse_pressed args
  end

end


MyApp.new  unless defined? $app
