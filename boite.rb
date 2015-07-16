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
        @inputs = {}
        @input_bangs = []
        
        input_list.each do |input|
          name = "input_bang_" + input

          create_input_bang name, input
          @inputs[input] = nil

          ## TODO: input placement
          @input_bangs << @cp5.addButton(name)
            .setLabel("")
            .setSize(10, 10)
          tooltip name, input
        end
      end

      @cp5.getTooltip.setDelay(200);
      tooltip "translation_at_mouse", "Move"


      @cp5.update

      update_graphics
    end


    def translation_at_mouse
      @location.x, @location.y = @applet.mouseX, @applet.mouseY
    end

    def update_graphics
      @location_handle.setPosition(@location.x + 50, @location.y)
      @edit_button.setPosition(@location.x + 60, @location.y + 10)
      @delete_button.setPosition(@location.x + 60, @location.y + 20)


      if can_create? and @creation_bang != nil
        @creation_bang.setPosition(@location.x + 60, @location.y )
      end

      if has_input? and @input_bangs != nil
        @input_bangs.each_with_index do |bang, index|
          bang.setPosition(@location.x + (index * 15), @location.y )
        end
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

      ## propagate bangs
      if is_a_bang? 
        @out_links.each { |boite| boite.bang }
        return 
      end

      is_simple = check_simple_inputs
      is_mixed = check_mixed_inputs 

#      puts "simple " + is_simple.to_s
#      puts is_simple.to_s
      return if not (is_simple or is_mixed)
        
      ## build the input data. 
      @data = {}
      is_simple = get_simple_inputs
      get_mixed_inputs unless is_simple

      apply @data

      # if has_action? 
      #   apply @data
      # end
    end

    def get_simple_inputs
      input_list.each do |input_name|

        return false if not check_input input_name
        value = nil
        output_data = @inputs[input_name].data

        if output_data[input_name] != nil
          value = output_data[input_name]
        else 
          ## get the first value
          ## Todo get the first output value ?

          first_output_name = @inputs[input_name].output.split(",").first

          value = output_data[first_output_name]
        end


        @data[input_name] = value
      end
      true
    end

    def get_mixed_inputs
      @in_links.each do |input_boite|
       next if not input_boite.has_output?
        input_boite.output.split(",").each do |value_name|
          @data[value_name] = input_boite.data[value_name]
        end
      end
    end


    def check_mixed_inputs
      input_data = all_inputs
      contains_all = input_list.map do |input_name|  
        input_data.include? input_name
      end
      contains_all.all?
    end

    def check_simple_inputs
      input_list.each do |input_name|
        return false if @inputs[input_name] == nil
      end
      true
    end

    def check_input name
      not ((@inputs[name] == nil) or (not @inputs[name].has_output?) or (@inputs[name].is_a_bang?))
    end


    def all_inputs 
      in_array = @in_links.map do |boite| 
        next if not boite.has_output? or boite.is_a_bang?
        boite.output
      end
      in_array = in_array.join(",").split(",")
      in_array.each { |name| name.chomp! } 
    end

    def output_bang
      @applet.begin_link = self
    end

    def create_input_bang(name, input_name)

      define_singleton_method(name.to_sym) do  #input_proc(input_name))
        puts "bang in " + input_name
        return if @applet.begin_link == nil
        
        link = Link.new @applet.begin_link, self

        ## simple link 
        link.transmitted_values << input_name

        ## all links coming here and leaving there. 
        @in_links << @applet.begin_link
        @applet.begin_link.out_links << self
      
        ## where this input comes from. 
        @inputs[input_name] = @applet.begin_link unless @applet.begin_link.is_a_bang?

        ## store the link
        @applet.links << link
        @applet.begin_link = nil
      end

    end

    def input_proc input_name
    end


## disabled...
    def input_bang
    end


    def remove_input boite
      @in_links.delete boite
    end

    def remove_output boite
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
