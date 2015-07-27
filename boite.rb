require 'ostruct'

require './link'

module MSSP

  class InputBang
    attr_reader :boite, :controller, :index
    attr_reader :source, :name
    attr_reader :sources
    
    def initialize boite, name, controller, index
      @boite, @name, @controller, @index = boite, name, controller, index
      @sources = []
    end

    def controller_name ; "input_bang_" + @name ; end
    def fill_with source; @source = source ; end
    def is_filled? ; @source != nil ; end

    def unfill ; @source = nil ; end 
    
    def self.controller_name(name) ; "input_bang_" + name ; end

  end

  class Boite 
    
    attr_reader :name, :location, :out_links, :data
    attr_reader :input_space
    
    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end
  
    def initialize(name, applet)
      @name = name
      @id = rand(36**8).to_s(36)
      @applet = applet
      @file = "boites/core/" + @name + ".rb"

      @links = {}
      @out_links = []
      @input_space = 13

      load_code

      @location = Vec2D.new 100, 100

      @cp5 = ControlP5.new @applet, self
      @location_handle = @cp5.addButton("translation_at_mouse")
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
        @input_bangs = {}

        multi_input = create_input_bang "multi_input", -1
        @input_bangs["multi_input"] = multi_input
                
        ## define a bang for each input. 
        input_list.each_with_index do |input, index|

          input_bang = create_input_bang input, index
          @input_bangs[input] = input_bang
          define_input_bang_method input_bang
        end
      end

      @cp5.getTooltip.setDelay(200);
      tooltip "translation_at_mouse", "Move"

      @cp5.update

      update_graphics
    end

    def create_input_bang(input_name, index)
        name = InputBang::controller_name input_name
        controller = @cp5.addButton(name)
                     .setLabel("")
                     .setSize(10, 10)
        tooltip name, input_name
        input_bang = InputBang.new self, name, controller, index

    end


    

    def input_bang_multi_input
      puts "bang in multi_input"
      return if @applet.begin_link == nil

      input_bang = @input_bangs["multi_input"]
      
      link = Link.new @applet.begin_link, self, input_bang, -1 
      link.bang = @applet.begin_link.is_a_bang? 

      ## add the input...
      input_bang.sources << @applet.begin_link
      
      ## store the link
      @links[input_bang.name] = link 

      @applet.add_link(link, self)
    end


    
    ## inputs can be values, from multiple output. 
    ## inputs cannot be : bangs. 
    def define_input_bang_method(input_bang)

      define_singleton_method(input_bang.name.to_sym) do 
        puts "bang in " + input_bang.name

        return if @applet.begin_link == nil
        return if @applet.begin_link.is_a_bang?

        link = Link.new @applet.begin_link, self, input_bang, input_bang.index 

        ## simple link 
        link.transmitted_values << input_bang.name

        clear_prev_link(input_bang)

        input_bang.fill_with @applet.begin_link
        
        ## store the link
        @links[input_bang.name] = link 
        
        @applet.add_link(link, self)
      end

    end

    def clear_prev_link(input_bang)
      prev_link = @links[input_bang.name]
      @applet.delete_link prev_link if prev_link != nil
    end
    

    def translation_at_mouse
      @location.x, @location.y = @applet.mouseX, @applet.mouseY
    end

    def update_graphics
      update_common

      update_create if can_create? and @creation_bang != nil
      update_has_input if has_input? and @input_bangs != nil
      update_with_data if has_data? 
      update_bang if is_a_bang?
    end

    def update_common
      @location_handle.setPosition(@location.x + 50, @location.y)
      @edit_button.setPosition(@location.x + 60, @location.y + 10)
      @delete_button.setPosition(@location.x + 60, @location.y + 20)
    end

    def update_create
      @creation_bang.setPosition(@location.x + 60, @location.y )
    end


    def update_has_input
      @input_bangs.each_value do |bang|
        bang.controller.setPosition(@location.x + (bang.index * @input_space), @location.y )
      end
    end


    def update_with_data
      if @output_bang == nil
        @output_bang = @cp5.addBang("output_bang")
          .setLabel("")
          .setSize(10, 10)
        tooltip "output_bang", output_created_values
      end
      @output_bang.setPosition(@location.x, @location.y + 20)
    end

    def update_bang
      if @activation_bang == nil 
        @activation_bang = @cp5.addBang("bang")
          .setLabel("")
          .setSize(20, 20)
        tooltip "bang", "Bang!"
      end
      @activation_bang.setPosition(@location.x, @location.y)
    end


    def bang 

      ## propagate bangs
      if is_a_bang? 
        @out_links.each { |boite| boite.bang }
        return 
      end

      @data = {}
      
      has_all = load_inputs
      return if not has_all

      apply @data
      
#      is_simple = check_simple_inputs
#      is_mixed = check_mixed_inputs 

#      puts "simple " + is_simple.to_s
#      puts is_simple.to_s
#      return if not (is_simple or is_mixed)
        
      ## build the input data. 

#      is_simple = load_simple_inputs
#      load_mixed_inputs unless is_simple

      # if has_action? 
      #   apply @data
      # end
    end


    # def load_simple_inputs
    #   input_list.each do |input_name|

    #     return false if not check_plugged_input input_name
    #     value = nil
    #     output_data = @inputs[input_name].data

    #     if output_data[input_name] != nil
    #       value = output_data[input_name]
    #     else 
    #       ## get the first value
    #       ## Todo get the first output value ?

    #       first_output_name = @inputs[input_name].output.split(",").first

    #       value = output_data[first_output_name]
    #     end


    #     @data[input_name] = value
    #   end
    #   true
    # end

    # def load_mixed_inputs
    #   @in_links.each do |input_boite|
    #    next if not input_boite.has_output?
    #     input_boite.output.split(",").each do |value_name|
    #       @data[value_name] = input_boite.data[value_name]
    #     end
    #   end
    # end


    def check_inputs

    end

    def load_inputs


      ## load all the data from the multi-input 
      @input_bangs["multi_input"].sources.each do |input_boite|
        next if not input_boite.has_output?
        input_boite.output.split(",").each do |value_name|
          @data[value_name] = input_boite.data[value_name]
        end
      end

      
      ## load the data from the individual inputs
      input_list.each do |input_name|
        # create the variable

        ## best case, the input is plugged in a slot. 
        if check_plugged_input input_name

          ## all the data going in this input. 
          incoming_data = input_boite(input_name).data

          ## if there is a corresponding data. 
          if incoming_data[input_name] != nil
            @data[input_name] = incoming_data[input_name]
          else 
            ## get the first value
            first_output_name = input_boite_outputs(input_name).split(",").first
            @data[input_name] = incoming_data[first_output_name]
          end
        else

          # the value is not plugged, look into the multi-input
          return false if @data[input_name] == nil

        end


      end

      true
    end

    def check_plugged_input name ; @input_bangs[name].is_filled? ; end
    def input_boite name ; @input_bangs[name].source ; end
    def input_boite_outputs name ; @input_bangs[name].source.output ; end

    ## use of this ?
    def output_bang
      @applet.begin_link = self
    end

    def remove_input link, boite
      ## multi-input link. 
      if link.input_bang == @input_bangs["multi_input"]
        link.input_bang.sources.delete(boite)
      else
        ## simple link.. 
        link.input_bang.unfill
      end
    end

    def remove_output link, boite
      @out_links.delete boite
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

    def input_list 
      return [] if not has_input?
      (input.split ",").map { |input| input.chomp }
    end

    def output_created_values; has_output? ? output : "No output ";  end

    def update_global 
      update_graphics

      if @name == "always"
        bang
      end
    end

    def draw(graphics)

      if @location_handle.is_pressed 
        translation_at_mouse
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

    def parse_file file
#      s.replace "world"   #=> "world"
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
    end


  end 


end
