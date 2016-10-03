# -*- coding: utf-8 -*-

require 'jruby_art'
require 'jruby_art/app'
require 'jruby/core_ext'

# Processing::Runner
# Dir["#{Processing::RP_CONFIG['PROCESSING_ROOT']}/core/library/\*.jar"].each{ |jar| require jar }
# Processing::App::SKETCH_PATH = __FILE__   unless defined? Processing::App::SKETCH_PATH

# require 'osc-ruby'

require_relative 'skatolo'
require_relative 'room'
require_relative 'window'

class RoomWindow < Processing::App

  attr_reader :room, :ready

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  def settings
    size 800, 800, OPENGL
  end


  def setup
    @room = MSSP::Room.new self, 800, 800

    @ready = true
  end

  def draw
    background 100
    @room.draw
    image(@room.graphics, 0, 0, 800, 800)
  end

  def key_pressed(*keys)
    # @room.test
  end

  def mouse_pressed(*args)
    @room.mouse_pressed args
  end

end


RoomWindow.new  unless defined? $app
