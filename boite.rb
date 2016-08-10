require 'ostruct'

require './link'
require './input_bang'
require './boite_gui'

## Here to save the location
class Vec2D
  def encode_with encoder
    encoder['x'] = self.x
    encoder['y'] = self.y
  end

  def init_with coder
    self.x = coder['x']
    self.y = coder['y']
  end
end

module MSSP

  class Boite

    attr_reader :name, :location, :out_links, :data, :id

    def encode_with encoder
      encoder['name'] = @name
      # encoder['custom'] = @is_custom
      encoder['location'] = @location
      encoder['internal_data'] = @internal_data
      encoder['id'] = @id
      encoder['out_links'] = @out_links
      encoder['input_bangs'] = @input_bangs
    end

    def init_with coder
      puts "In coder !"

      # encoder['custom'] = @is_custom
      # encoder['location'] = @location

      @id = coder['id']
      @name = coder['name']
      @location = coder['location']
      @internal_data = coder['internal_data']
      @out_links = coder['out_links']
      @input_bangs = coder['input_bangs']
      init true
    end

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end

    def init deserialize
      @room = $engine
      @applet = $app if deserialize

      @deleting = false
      @file, @is_custom = @room.find_file @name
      @error = 0
      @data = {}

      init_gui if room_gui_loaded?

      if not deserialize
        edit if not File.exists? @file
      end

      load_code

      create_input_bangs unless deserialize
      define_input_bangs

      if room_gui_loaded?
        init_default_buttons
        init_optional_buttons
        update_graphics
      end
    end

    def initialize(name, applet, room)
      @name, @applet, @room = name, applet, room
      @id = rand(36**8).to_s(36)

      @location = Vec2D.new 100, 100
      @out_links = []
      @input_bangs = {}
      @data = {}

      init false
    end

    def define_input_bangs
      input_list.each_with_index do |input, index|
        if @input_bangs[input] != nil
          define_input_bang_method @input_bangs[input]
        else
          puts "No input Bang " + input
        end
      end
    end

    def create_input_bangs
      if has_input?
        multi_input = InputBang.new self, "multi_input", -1
        @input_bangs["multi_input"] = multi_input

        ## define a bang for each input.
        input_list.each_with_index do |input, index|
          input_bang = InputBang.new self, input, index
          @input_bangs[input] = input_bang
        end
      end
    end

    #### Create a link.
    ## Activated by the GUI
    def input_bang_multi_input
      puts "bang in multi_input"
      return if @room.begin_link == nil

      add_multi_input @room.begin_link

      create_add_link(@room.begin_link, @input_bangs["multi_input"])
    end

    ## inputs can be values, from multiple output.
    ## inputs cannot be : bangs.
    def define_input_bang_method(input_bang)

      define_singleton_method(input_bang.controller_name.to_sym) do
        puts "here define..."
        puts "bang in " + input_bang.name

        return if @room.begin_link == nil
        return if @room.begin_link.is_a_bang?

        clear_input_bang_links input_bang

        # add the input.
        add_single_input input_bang, @room.begin_link

        # create and add the link
        create_add_link(@room.begin_link, input_bang)
      end
    end

    # clear the previous link(s)
    def clear_input_bang_links input_bang
      input_bang.links.each { |link| link.delete }
    end

    ## Inputs are stored inside the input_bangs.
    def add_single_input input_bang, begin_link
      input_bang.fill_with begin_link
      begin_link.out_links << input_bang
    end

    ## Inputs are stored inside the input_bangs.
    def add_multi_input begin_link
      @input_bangs["multi_input"].sources << begin_link.id
      begin_link.out_links << @input_bangs["multi_input"]
    end

    def create_add_link begin_link, input_bang
      link = Link.new begin_link, self, input_bang
      link.bang = begin_link.is_a_bang?
      @room.begin_link = nil
      input_bang.links << link
    end

    #################
    ## Code execution
    def bang
      return if @deleting

      ## propagate bangs only
      if is_a_bang?
        bang_on_outputs
        return
      end


      if has_input?
        has_all = load_inputs

        @error = $app.color 150, 150, 2550 if not has_all
        return if not has_all
      end

      begin
        @error = 0
        apply
      rescue
        # p "error"
        ## TODO: something better than this color stuff.
        @error = $app.color 255, 200, 0
      end

      # propagate
      bang_on_outputs
    end

    def bang_on_outputs
      boites = @out_links.collect {|input_bang| input_bang.boite }
      boites.uniq.each { |boite| boite.bang }
    end


    def load_inputs
      return if @deleting

      ## load all the data from the multi-input
      @input_bangs["multi_input"].sources.each do |boite_src|

        #        next if not boite_src.has_output?
        if boite_src.has_output?
          boite_src.output.split(",").each do |value_name|
            @data[value_name] = boite_src.data[value_name]
          end
        else
          ## no declared output, get the hidden data...
          if boite_src.data != nil && boite_src.data.class == Hash

            @data.merge! boite_src.data
          end
        end
      end

      ## load the data from the individual inputs
      input_list().each do |input_name|
        # create the variable

        ## best case, the input is plugged in a slot.
        if check_plugged_input input_name

          ## all the data going in this input.
          incoming_data = boite_src(input_name).data

          ## if there is a corresponding data.
          if incoming_data[input_name] != nil
            @data[input_name] = incoming_data[input_name]
          else
            ## get the first value
            first_output_name = boite_src_outputs(input_name).split(",").first
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


    def delete
      @room.remove self
      @deleting = true

      puts "delete input_bangs"
      @input_bangs.each_value do |input_bang|
        clear_input_bang_links input_bang
      end

      puts "delete out_links"
      ## delete the output
      @out_links.each do |input_bang|
        clear_input_bang_links input_bang
      end


      ## remove the input links and output links
      delete_gui if room_gui_loaded?

      if @room.begin_link == self
        @room.begin_link = nil
        ## clear the data structures
        # @out_links = nil
        # @input_bangs = nil
      end
    end

    def remove_input link, boite
      ## if multi-input link.
      if link.input_bang == @input_bangs["multi_input"]
        link.input_bang.sources.delete_if do |source|
          source == boite
        end
      else
        ## simple link..
        link.input_bang.unfill
      end
    end

    def remove_output link, boite
      @out_links.delete_if do |input_bang|
        input_bang.boite == boite
      end
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
    def check_plugged_input name ; @input_bangs[name].is_filled? ; end
    def boite_src name ; @input_bangs[name].source ; end
    def boite_src_outputs name ; @input_bangs[name].source.output ; end

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

      update
    end

    def translation_at_mouse
      @location.x, @location.y = @applet.mouseX - 50, @applet.mouseY
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

      ## Why first eval ?
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


    def create_button ; create ; end

    def edit
      %x( nohup scite #{@file} & )
      return if not File.exists? @file
      load_code
    end


    java_signature 'processing.core.PGraphics getGraphics()'
    def getGraphics
      @room.getGraphics
    end

    Boite.become_java!
  end

end
