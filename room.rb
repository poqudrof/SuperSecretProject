require_relative 'engine'
require_relative 'boite'

## GUI for boites loaded here
require_relative 'boite_gui'

module MSSP
  class Room < Engine

    include Processing::Proxy
    attr_reader :graphics, :skatolo
    attr_accessor :begin_link
    attr_accessor :text_field

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end

    def initialize (applet, width, height)

      # TODO: proper installation...
      lib = "/home/jiii/repos/SuperSecretProject/boites/"
      work = $app.sketchPath + "/testBoites/"

      super(work, lib)
      @applet, @width, @height = applet, width, height
      @graphics = @applet.createGraphics(@width, @height)

      @begin_link = nil
      @links = []

      @skatolo = Skatolo.new @applet, self
      @applet.registerMethod("mousePressed", self)

      @to_delete = []
    end

    def draw
      @graphics.beginDraw
      @graphics.background 55, 0, 0

      @boites.each_value do |boite|
        boite.global_draw @graphics
      end

      draw_links
      draw_help_boites
      
      run

      @graphics.endDraw
    end

    def draw_links
      @graphics.fill 0
      @graphics.stroke 180
      @graphics.strokeWeight 1

      @boites.each_value do |boite|
        boite.out_links.each do |input_bang|
          input_bang.links.each do |link|

            @graphics.strokeWeight 1
            bold = link.check_click @applet.mouse_x, @applet.mouse_y
            @graphics.strokeWeight 2 if bold
            link.draw @graphics
          end
        end
      end

      if @begin_link != nil
        @graphics.fill 0
        @graphics.stroke 255
        @graphics.strokeWeight 1
        @graphics.line(@begin_link.location.x + 5,
                       @begin_link.location.y + 20 + 5,
                       @applet.mouse_x,
                       @applet.mouse_y)
      end
    end

    def mouse_pressed(args)

      @boites.each_value do |boite|
        boite.out_links.each do |input_bang|
          input_bang.links.each do |link|
            selected = link.check_click @applet.mouse_x, @applet.mouse_y
            if selected
              link.delete
            end
          end
        end
      end

      if mouseButton == Processing::Proxy::RIGHT
        if @begin_link != nil
          @begin_link = nil
        else
          remove_textfield
        end

      end

      if(@applet.mouseEvent != nil and @applet.mouseEvent.getClickCount == 2)
        if @text_field == nil
          @text_field = @skatolo.addTextfield("boite")
                        .setPosition(mouse_x, mouse_y)
                        .setSize(150, 20)
          @skatolo.update
        end
      end
    end


    ## 
    def key_pressed(*keys)
      @new_key_pressed if @text_field != nil 
    end

    def draw_help_boites

      if @text_field != nil
        partial_name = @text_field.text 
        names = find_core_boite_names
        user_boite_names = find_user_boite_names

        start_names = names.find_all { |n| n.start_with? partial_name }
        inside_names = names.find_all { |n| n.include? partial_name }
        core_names = (start_names + inside_names).uniq

        @graphics.noStroke
        @graphics.fill 255
        @graphics.pushMatrix
        @graphics.translate @text_field.position.x,
                            @text_field.position.y + 27
        @graphics.pushMatrix
        incr = 15

        core_names.each do |name|
          @graphics.text(name, 0, 20)
          @graphics.translate 0, incr
        end
        
        @graphics.popMatrix
        @graphics.pushMatrix
        @graphics.translate 0, -60
        user_boite_names.each do |name|
          
          @graphics.text(name, 0, 20)
          @graphics.translate 0, -incr

        end
        @graphics.popMatrix
        @graphics.popMatrix
        
      end
    end
      
    
    def boite name
      if name == ""
        remove_textfield
        return
      end

      if is_a_number name
        boite = Boite.new "number", @applet, self
        boite.set_value name.to_f
        add_created_boite boite
        return boite
      end

      if is_load name
        puts "In load !"
        file_name = name.split("load ")[1]
        load_program file_name
        remove_textfield
        return
      end

      if is_save name
        puts "in Save !"
        file_name = name.split("save ")[1]
        save_program file_name
        remove_textfield
        return
      end

      boite = Boite.new boite_value, @applet, self
      ## check if it managed to be created... 
      add_created_boite boite unless boite.deleting
      boite
    end


    def add_created_boite boite
      boite.location.x = @text_field.position.x
      boite.location.y = @text_field.position.y
      @boites[boite.id] = boite
      remove_textfield
    end

    def is_a_number name
      return (name =~ /\A[-+]?\d*\.?\d+\z/) == 0
    end

    def is_load name
      name.start_with? "load "
    end

    def is_save name
      name.start_with? "save "
    end

    def remove_textfield
      @skatolo.remove "boite"
      @text_field = nil
    end

    java_signature 'processing.core.PGraphics getGraphics()'
    def getGraphics
      @graphics
    end

    java_signature 'void mousePressed()'
    def mousePressed
      mouse_pressed
    end

    Room.become_java!
  end
end
