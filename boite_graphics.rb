module MSSP

  class Boite

    def self.room_gui_loaded ;  true ; end

    def init_gui
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
      if can_create?
        @create_button = @skatolo.addButton("create_button")
                         .setLabel("create")
                         .setSize(40, 10)
        tooltip "create_button", "create data"
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
      @skatolo.update
    end

    def create_input_bang(input_name, index)
      name = InputBang::controller_name input_name
      controller = @skatolo.addButton(name)
                   .setLabel("")
                   .setSize(10, 10)
      tooltip name, input_name
      input_bang = InputBang.new self, name, controller, index
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

    def delete
      @room.remove self
      # puts @skatolo.getAll
      @skatolo.getAll.each do |controller|
        @skatolo.remove controller
      end
      @skatolo.delete
      @skatolo = nil
      puts "Delete ended. "
    end

    def tooltip(name, text) ; @skatolo.getTooltip.register(name, text); end
  end
end
