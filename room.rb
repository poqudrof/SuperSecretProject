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
      super()
      @applet, @width, @height = applet, width, height
      @graphics = @applet.createGraphics(@width, @height)

      @begin_link = nil

      @skatolo = Skatolo.new @applet, self
      @applet.registerMethod("mousePressed", self)

      @boite_rect = Boite.new "rect", @applet, self
      @boite_graphics = Boite.new "current_graphics", @applet, self
      @boite_bang = Boite.new "bang", @applet, self
      @boite_always = Boite.new "always", @applet, self

      @boites << @boite_graphics
      @boites << @boite_rect
      @boites << @boite_bang
      @boites << @boite_always

      @boite_rect.location.x = 300
      @boite_bang.location.y = 300
      @boite_always.location.y = 300
      @boite_always.location.x = 300

      @to_delete = []
    end

    def draw


      @graphics.beginDraw
      @graphics.background 55, 0, 0

      @boites.each do |boite|
        boite.global_draw @graphics
        # @boites.each { |boite| boite.update_global }
#        boite.update_global
      end

      draw_links

      run

      @graphics.endDraw
    end

    def draw_links
      @graphics.fill 0
      @graphics.stroke 180
      @graphics.strokeWeight 1
      @links.each do |link|
        @graphics.strokeWeight 1
        bold = link.check_click @applet.mouse_x, @applet.mouse_y
        @graphics.strokeWeight 2 if bold
        link.draw @graphics
      end

      if @begin_link != nil
        @graphics.fill 0
        @graphics.stroke 255
        @graphics.strokeWeight 1
        @graphics.line @begin_link.location.x, @begin_link.location.y, @applet.mouse_x, @applet.mouse_y
      end
    end

    def mouse_pressed(args)
      @links.each do |link|
        selected = link.check_click @applet.mouse_x, @applet.mouse_y

        if selected
          delete_link link
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


    def remove boite
      @boites.delete boite
    end


    def boite name

      if name == ""
        remove_boite
        return
      end

      if is_a_number name
        boite = Boite.new "number", @applet, self
        boite.set_value name.to_f
        add_boite boite
        return
      end

      boite = Boite.new boite_value, @applet, self
      add_boite boite
    end

    def add_boite boite
      boite.location.x = @text_field.position.x
      boite.location.y = @text_field.position.y
      @boites << boite
      remove_boite
    end

    def is_a_number name
      return (name =~ /\A[-+]?\d*\.?\d+\z/) == 0
    end

    def remove_boite
      @skatolo.remove "boite"
      @text_field = nil
    end


    def delete_link link
      @links.delete link
      link.delete
    end

    def add_link(link, boite)
      @begin_link.out_links << boite
      @links << link
      @begin_link = nil
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
