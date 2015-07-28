# -*- coding: utf-8 -*-

require 'ruby-processing' 
require 'jruby/core_ext'

Processing::Runner 
Dir["#{Processing::RP_CONFIG['PROCESSING_ROOT']}/core/library/\*.jar"].each{ |jar| require jar }
Processing::App::SKETCH_PATH = __FILE__   unless defined? Processing::App::SKETCH_PATH

require './cp5' 
require './boite'
require './room'

class MyApp < Processing::App

  load_library :vecmath

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  def setup
    size 800, 800, OPENGL

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
