module MSSP

  class Boite

    attr_reader :input_space
    def self.room_gui_loaded ;  true ; end

    def init_gui
      @input_space = 13
      @skatolo = Skatolo.new @applet, self
      @skatolo.setGraphics @room.getGraphics
      @skatolo.getTooltip.setDelay(200);
    end

    def init_default_buttons
      @location_handle = @skatolo.addButton("translation_at_mouse")
                         .setLabel("")
                         .setSize(10, 20)

      tooltip "translation_at_mouse", "Move"

      @edit_button = @skatolo.addButton("edit")
                     .setLabel("edit")
                     .setSize(30, 10)

      @delete_button = @skatolo.addButton("delete")
                       .setLabel("del")
                       .setSize(13, 10)

      @skatolo.update
    end

    def init_optional_buttons

      if @input_bangs != nil
        @input_bangs.each_value do |input_bang|
          create_input_bang_graphics(input_bang)
        end
      end

      @skatolo.update
    end

    def create_input_bang_graphics(input_bang)
      controller = @skatolo.addButton(input_bang.controller_name)
                   .setLabel("")
                   .setSize(10, 10)
      ## just the bang name as a tooltip
      tooltip input_bang.controller_name, input_bang.name
      input_bang.controller = controller
    end

    def update_graphics
      update_common

      update_create if can_create? and @create_button != nil
      update_has_input if has_input? and @input_bangs != nil
      update_with_data if has_data?
#      update_bang if is_a_bang?
    end

    def update_common
      @location_handle.setPosition(@location.x + 50, @location.y)
      @edit_button.setPosition(@location.x + 60, @location.y + 10)
      @delete_button.setPosition(@location.x + 60, @location.y + 20)
    end

    def update_create
      @create_button.setPosition(@location.x + 60, @location.y )
    end

    def update_has_input
      @input_bangs.each_value do |bang|
        bang.controller.setPosition(@location.x + (bang.index * @input_space), @location.y )
      end
    end

    def update_with_data
      if @output_bang == nil
        @output_bang = @skatolo.addBang("output_bang")
          .setLabel("")
          .setSize(10, 10)
        tooltip "output_bang", output_created_values
      end
      @output_bang.setPosition(@location.x, @location.y + 20)
    end

    def update_bang
      if @activation_bang == nil
        @activation_bang = @skatolo.addBang("bang")
          .setLabel("")
          .setSize(20, 20)
        tooltip "bang", "Bang!"
      end
      @activation_bang.setPosition(@location.x, @location.y)
    end

    def output_bang
      @room.begin_link = self
    end

    def delete_gui
      @skatolo.getAll.each do |controller|
        @skatolo.remove controller
      end
      @skatolo.delete
      @skatolo = nil
    end

    def tooltip(name, text) ; @skatolo.getTooltip.register(name, text); end
  end
end
