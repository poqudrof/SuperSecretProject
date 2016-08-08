require 'ostruct'

require './link'
require './boite_graphics'


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

    def initialize(name, applet, room)
      @name, @applet, @room = name, applet, room

      @id = rand(36**8).to_s(36)
      @file = "boites/core/" + @name + ".rb"

      @links = {}
      @out_links = []
      @input_space = 13

      @error = 0
      @location = Vec2D.new 100, 100


      if room_gui_loaded?
        init_gui
        init_default_buttons
      end

      # check if code exists
      puts "No file, we create it."
      edit if not File.exists? @file
      load_code

      if room_gui_loaded?
        init_optional_buttons
        update_graphics
      end
    end


    def input_bang_multi_input
      puts "bang in multi_input"
      return if @room.begin_link == nil

      input_bang = @input_bangs["multi_input"]

      link = Link.new @room.begin_link, self, input_bang, -1
      link.bang = @room.begin_link.is_a_bang?

      ## add the input...
      input_bang.sources << @room.begin_link

      ## store the link
      @links[input_bang.name] = link

      @room.add_link(link, self)
    end



    ## inputs can be values, from multiple output.
    ## inputs cannot be : bangs.
    def define_input_bang_method(input_bang)

      define_singleton_method(input_bang.name.to_sym) do
        puts "bang in " + input_bang.name

        return if @room.begin_link == nil
        return if @room.begin_link.is_a_bang?

        link = Link.new @room.begin_link, self, input_bang, input_bang.index

        ## simple link
        link.transmitted_values << input_bang.name

        clear_prev_link(input_bang)

        input_bang.fill_with @room.begin_link

        ## store the link
        @links[input_bang.name] = link

        @room.add_link(link, self)
      end

    end

    def clear_prev_link(input_bang)
      prev_link = @links[input_bang.name]
      @room.delete_link prev_link if prev_link != nil
    end


    def translation_at_mouse
      @location.x, @location.y = @applet.mouseX - 50, @applet.mouseY
    end

    ## Code execution
    def bang

      ## propagate bangs only
      if is_a_bang?
        @out_links.each { |boite| boite.bang }
        return
      end

      if @data == nil
        @data = {}
      end

      if has_input?
        has_all = load_inputs
        return if not has_all
      end

      begin
        @error = 0
        apply
      rescue
        p "error"
        @error = color 255, 200, 0
      end

      # propagate
      @out_links.each { |boite| boite.bang }
    end


    def load_inputs

      ## load all the data from the multi-input
      @input_bangs["multi_input"].sources.each do |input_boite|

#        next if not input_boite.has_output?

        if input_boite.has_output?
          input_boite.output.split(",").each do |value_name|
            @data[value_name] = input_boite.data[value_name]
          end
        else
          ## no declared output, get the hidden data...
          if input_boite.data != nil && input_boite.data.class == Hash

            @data.merge! input_boite.data
          end
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
#          puts "missing " + input_name  if @data[input_name] == nil

          return false if @data[input_name] == nil
        end
      end

      true
    end

    def check_plugged_input name ; @input_bangs[name].is_filled? ; end
    def input_boite name ; @input_bangs[name].source ; end
    def input_boite_outputs name ; @input_bangs[name].source.output ; end

    def output_bang
      @room.begin_link = self
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


    def can_create? ; defined? create ; end
    def has_data? ;  defined? @data ; end
    def has_action? ;  defined? apply ; end
    def is_new? ; File.exists? @file ; end
    def has_input? ; defined? input ; end
    def has_output? ; defined? output ; end
    def is_a_bang? ; @bang != nil ; end
    def is_a_bang ; @bang = true ; end
    def room_gui_loaded? ; defined? Boite::room_gui_loaded ; end

    def input_list
      return [] if not has_input?
      (input.split ",").map { |input| input.chomp }
    end

    def output_list
      return [] if not has_output?
      (output.split ",").map { |output| output.chomp }
    end

    def output_created_values ; has_output? ? output : "Forward data";  end


    def update_global
      if room_gui_loaded?
        update_graphics
        translation_at_mouse if @location_handle.is_pressed
      end

      ## TODO: change this always stuff to somewhere else
      if @name == "always"
        bang
      end

      update
    end

    ## Draw common elements to all boites.
    def global_draw(graphics)
      graphics.pushMatrix
      graphics.translate @location.x, @location.y

      graphics.noStroke
      graphics.fill @error
      graphics.rect(0, 0, 50, 20)

      graphics.translate(0, - 5)
      graphics.fill 255
      graphics.text @name, 0, 0

      graphics.translate(0, 5)
      draw graphics

      graphics.popMatrix
    end

    ## functions to override
    def draw graphics;  end
    def update ; bang ; end
    def apply ; end

    ## Code related methods
    def load_code
      return if not File.exists? @file

      file = File.read @file
      begin
        ## first eval
        instance_eval file
      rescue
        puts "syntax error in " + @file.to_s
        edit nil
      end

      ## Remove the input and output functions, fills the in/output_list
      remove_input_output file

      ## Replace output with data access
      output_list.each do |output_name|
        file.gsub! parsed_name(output_name), long_name(output_name)
      end

      ## Replace input with data access
      input_list.each do |input_name|
        file.gsub! parsed_name(input_name), long_name(input_name)
      end

      instance_eval file

      if defined? create
        @data = {}
        #create
      end
    end

    def remove_input_output(file)
      file.gsub! /def input(\s*(.*)\s*end)/, ""
      file.gsub! /def output(\s*(.*)\s*end)/, ""
    end

    def parsed_name (name)
      /(?<before>[\(\)=.\s,])#{name}(?<after>[\(\)=.\s,])/
    end

    def long_name (name)
      "\\k<before>@data[\"#{name}\"]\\k<after>"
    end


    def parse_file file
#      s.replace "world"   #=> "world"
    end

    def create_button
      p caller
      # p @create_button.isPressed.to_s
      p @create_button.get_value.to_s
      create
    end

    def edit
      %x( nohup scite #{@file} & )
      return if not File.exists? @file
      load_code
    end


    def create_data (value, name)
      data = {}
      data[name] = value
      data
    end

    java_signature 'processing.core.PGraphics getGraphics()'
    def getGraphics
      @room.getGraphics
    end

    Boite.become_java!
  end


end
