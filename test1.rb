# -*- coding: utf-8 -*-

require 'ruby-processing' 
require 'jruby/core_ext'

Processing::Runner 
Dir["#{Processing::RP_CONFIG['PROCESSING_ROOT']}/core/library/\*.jar"].each{ |jar| require jar }
Processing::App::SKETCH_PATH = __FILE__   unless defined? Processing::App::SKETCH_PATH

require './cp5' 
require './boite'

class MyApp < Processing::App

  load_library :vecmath

  include MSSP

  attr_reader :cp5
  attr_accessor :once
  attr_accessor :begin_link
  attr_reader :links

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end
  
  def setup
    size 800, 800, OPENGL
    
    @boites = []
    @links = []

    puts "setup"
    
    @cp5 = ControlP5.new self, self
#    $cp5 = @cp5

    @cp5.update

    @boite_rect = Boite.new "rect", self
    @boite_graphics = Boite.new "main_graphics", self

    @boite_bang = Boite.new "bang", self
    @boite_always = Boite.new "always", self

    @boites << @boite_graphics
    @boites << @boite_rect
    @boites << @boite_bang
    @boites << @boite_always

    @boite_rect.location.x = 300
    @boite_bang.location.y = 300
    @boite_always.location.y = 300
    @boite_always.location.x = 300


  end

  def remove boite
    @boites.delete boite
  end


  def boite name

    if name == "" 
      remove_boite
      return
    end
    puts "In function boite " + name +  " " + boite_value

    ## TODO: try... catch
    boite = Boite.new boite_value, self
    boite.location.x = @text_field.position.x
    boite.location.y = @text_field.position.y
    @boites << boite
    remove_boite
  end

  def remove_boite
    @cp5.remove "boite"
    @text_field = nil

  end

  def draw 
    background 55

    ## todo : put list of functions
    @boites.each do |boite|
      boite.update_global
      boite.update if defined? boite.update
      boite.draw g
    end

    fill 0
    stroke 180
    strokeWeight 1
    
    @links.each do |link|
      link.draw g
    end

    if @begin_link != nil
      fill 0
      stroke 255
      strokeWeight 1
      line @begin_link.location.x, @begin_link.location.y, mouse_x, mouse_y
    end


  end

  def mouse_dragged

  end

  def mouse_pressed

    @links.each do |link|
     selected = link.check_click mouse_x, mouse_y

      if selected
        @links.delete link
        link.delete 
      end
    end
    puts @links.size


    if(mouseEvent != nil and mouseEvent.getClickCount == 2)
      
      if @text_field == nil
        @text_field = @cp5.addTextfield("boite")
          .setPosition(mouse_x, mouse_y)
          .setSize(150, 20)
        @cp5.update
      end
    end

  end

  
end



MyApp.new  unless defined? $app
