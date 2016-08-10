require './engine'
require './boite'

module MSSP
  class Room < Engine

    include Processing::Proxy
    attr_reader :graphics
    attr_accessor :begin_link

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end

    def initialize (applet, width, height)

      lib = $app.sketchPath + "/boites/"
      work = $app.sketchPath + "/test/"

      super(work, lib)
      @applet, @width, @height = applet, width, height
      @graphics = @applet.createGraphics(@width, @height)

      @begin_link = nil
      @links = []

      @skatolo = Skatolo.new @applet, self
      @applet.registerMethod("mousePressed", self)

      @boite_rect = Boite.new "rect", @applet, self
      @boite_graphics = Boite.new "current_graphics", @applet, self
      @boite_bang = Boite.new "bang", @applet, self
      @boite_always = Boite.new "always", @applet, self

      add @boite_graphics
      add @boite_rect
      add @boite_bang
      add @boite_always

      @boite_rect.location.x = 300
      @boite_bang.location.y = 300
      @boite_always.location.y = 300
      @boite_always.location.x = 300

      @to_delete = []
    end

    def draw
      @graphics.beginDraw
      @graphics.background 55, 0, 0

      @boites.each_value do |boite|
        boite.global_draw @graphics
      end

      draw_links

      run

      @graphics.endDraw
    end

    def draw_links
      @graphics.fill 0
      @graphics.stroke 180
      @graphics.strokeWeight 1

      @boites.each_value do |boite|

        puts "links " + boite.out_links.size.to_s
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
        boite.out_links do |link|

#      @links.each do |link|
          selected = link.check_click @applet.mouse_x, @applet.mouse_y
          if selected
            link.delete
          end
        end
      end

      if mouseButton == Processing::Proxy::RIGHT
        @begin_link = nil if @begin_link != nil
      end

      if(@applet.mouseEvent != nil and @applet.mouseEvent.getClickCount == 2)
        if @text_field == nil
          @text_field = @skatolo.addTextfield("boite")
                        .setPosition(mouse_x, mouse_y)
                        .setSize(150, 20)
          puts "add text_field"
          @skatolo.update
        end
      end
    end


    def boite name
      if name == ""
        remove_boite
        return
      end

      if is_a_number name
        boite = Boite.new "number", @applet, self
        boite.set_value name.to_f
        add_created_boite boite
        return
      end

      boite = Boite.new boite_value, @applet, self
      add_created_boite boite
    end

    def add_created_boite boite
      boite.location.x = @text_field.position.x
      boite.location.y = @text_field.position.y
      @boites[boite.id] = boite
      remove_boite
    end

    def is_a_number name
      return (name =~ /\A[-+]?\d*\.?\d+\z/) == 0
    end

    def remove_boite
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
