require 'ostruct'

require './link'

module MSSP


  class Boite 
    
    attr_reader :name, :location, :out_links, :in_links, :data
    
    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end
  
    def initialize(name, applet)
      @name = name
      @id = rand(36**8).to_s(36)
      @applet = applet
      @file = "boites/core/" + @name + ".rb"
      @in_links = []
      @out_links = []

      load_code

      @location = Vec2D.new 100, 100

      @cp5 = ControlP5.new @applet, self
      @location_handle = @cp5.addButton("translation")
        .setLabel("")
        .setSize(10, 20)

      @edit_button = @cp5.addButton("edit")
        .setLabel("edit")
        .setSize(30, 10)

      @delete_button = @cp5.addButton("delete")
        .setLabel("del")
        .setSize(13, 10)

      if can_create? 
        @creation_bang = @cp5.addButton("create")
          .setLabel("create")
          .setSize(40, 10)
        tooltip "create", "create data"
      end

      if has_input?
        @input_bang = @cp5.addButton("input_bang")
          .setLabel("")
          .setSize(10, 10)
        tooltip "input_bang", input
      end

      @cp5.getTooltip.setDelay(200);
      tooltip "translation", "Move"


      @cp5.update

      update_graphics
    end


    def translation
      @location.x, @location.y = @applet.mouseX, @applet.mouseY
    end

    def update_graphics
      @location_handle.setPosition(@location.x + 50, @location.y)
      @edit_button.setPosition(@location.x + 60, @location.y + 10)
      @delete_button.setPosition(@location.x + 60, @location.y + 20)


      if can_create? and @creation_bang != nil
        @creation_bang.setPosition(@location.x + 60, @location.y )
      end

      if has_input? and @input_bang != nil
        @input_bang.setPosition(@location.x + 0, @location.y )
        tooltip "input_bang", input
      end
      

      if has_data? 
        if @output_bang == nil
          @output_bang = @cp5.addBang("output_bang")
            .setLabel("")
          .setSize(10, 10)
        tooltip "output_bang", output_created_values
        end


        @output_bang.setPosition(@location.x, @location.y + 20)
      end

      if is_a_bang?
        if @activation_bang == nil 
          @activation_bang = @cp5.addBang("bang")
            .setLabel("")
            .setSize(20, 20)
          tooltip "bang", "Bang!"
        end
        
        @activation_bang.setPosition(@location.x, @location.y)
      end
      

    end

    def bang 

#      puts @name + " Bang !! "

      ## propagate bangs...
      if is_a_bang? 
        @out_links.each { |boite| boite.bang }
        return 
      end

      ## not all inputs are here... 
      return if not check_inputs
        
      ## build the input data. 

      @data = {}
      @in_links.each do |input_boite|

        next if not input_boite.has_output?

        input_boite.output.split(",").each do |value_name|
          @data[value_name] = input_boite.data[value_name]
        end
      end

      apply @data

      # if has_action? 
      #   apply @data
      # end

    end

    def check_inputs

      input_data = (@in_links.map{ |boite| boite.output if boite.has_output?}.join ",").split ","

      contains_all = input.split(",").map do |input_name|  
        input_data.include? input_name
      end

      # all true ?
      contains_all.all?
    end


    def output_bang
      @applet.begin_link = self
    end

    def input_bang

      return if @applet.begin_link == nil

      link = Link.new @applet.begin_link, self
      @in_links << @applet.begin_link
      @applet.begin_link.out_links << self

      @applet.links << link
      @applet.begin_link = nil
    end


    def get_binding ; binding ; end
    def tooltip(name, text) ; @cp5.getTooltip.register(name, text); end

    def can_create? ; defined? create ; end
    def has_data? ;  defined? @data ; end 
    def has_action? ;  defined? apply ; end 
    def is_new? ; File.exists? @file ; end
    def has_input? ; defined? input ; end
    def has_output? ; defined? output ; end
    def is_a_bang? ; @data == "bang" ; end
    def is_a_bang ; @data = "bang" ; end

    def output_created_values; has_output? ? output : "No output ";  end

    def update 

      if @name == "always"
        bang
      end
    end

    def draw(graphics)

      update_graphics

      if @location_handle.is_pressed 
        translation
      end

      graphics.pushMatrix
      graphics.translate @location.x, @location.y
      graphics.fill 200
      graphics.rect(0, 0, 50, 20)

      graphics.translate(0, - 5)
      graphics.text @name, 0, 0
      graphics.popMatrix
    end
    

    ## Code related methods

    def load_code

      edit if not File.exists? @file

      file = File.read @file
      instance_eval file

    end


    def edit
      %x( scite #{@file} )
      load_code
    end

    def delete
      @to_remove = true

      @cp5.setAutoDraw false

      @applet.remove self

      @cp5.remove "edit"
      @cp5.remove "delete"
      
      puts @cp5.getAll

      @cp5.getAll.each do |controller| 
        @cp5.remove controller
      end

    end

    
    def create_data (value, name)
      data = {}
      data[name] = value
      data

      # data.out = {}
      # data.out[name] = value

      # data = OpenStruct.new 
      # data.graphics = value
      # data.out = {}
      # data.out[name] = value
      # data
    end


  end 


end
