# -*- coding: utf-8 -*-

require 'jruby/core_ext'
require 'ruby-processing' 
Processing::App::SKETCH_PATH = __FILE__

Processing::App::load_libraries 'controlP5'

module Cp5
  include_package 'fr.inria.controlP5'
  include_package 'fr.inria.controlP5.events'
  include_package 'fr.inria.controlP5.gui.controllers'
end 


class Sketch < Processing::App
  
  load_libraries 'controlP5'
  attr_accessor :run_once, :cp5
  
  def setup 
    size(400, 400, OPENGL)
    frame.setResizable true unless frame == nil
    
    @run_once = false
  end 


  java_field "java.lang.Float sliderValue"

  def once 
    @cp5 = Cp5::ControlP5.new(self) if @cp5 == nil
    puts "Hello " 

#    cp5.addBang("bang").setPosition(100, 100).setSize(280, 40).setLabel("changeBackground")
    @cp5.addSlider("sliderValue").setPosition(100,50).setRange(0,255)  unless @cp5 == nil

#    bang = Cp5::Bang.new(@cp5, "Test").setPosition(100, 100)


    puts "slider value", @sliderValue

  end
  $app.once if $app
  


  def bang
    puts "BANG"
  end

  def controlEvent(theEvent)
    puts theEvent
  end

    # for (int i=0;i<col.length;i++) {
    #     if (theEvent.getController().getName().equals("bang"+i)) {
    #         col[i] = color(random(255));
    #       }
    #     }
  
  # println(
  # "## controlEvent / id:"+theEvent.getController().id()+
  #   " / name:"+theEvent.getController().name()+
  #   " / label:"+theEvent.getController().label()+
  #   " / value:"+theEvent.getController().value()
  #   );

  def draw 
    if @run_once 
      once
      @run_once = false
    end

    background 100
    rect(10, 10, 10, 100)
  end 

end 


Sketch.new unless defined? $app
