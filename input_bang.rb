require_relative 'input_bang_base'

module MSSP

  class InputBang < InputBangBase

    def fill_with source ; @source = source.id ; end
    def is_filled? ; @source != nil ; end

    def clear
      if is_filled?
        ## clear in the output
        source.remove_output self
        @source = nil
        clear_links
      end
    end

    def remove boite ; clear; end

    def source
      if is_filled?
        from_engine @source
      else
        nil
      end
    end

  end

end
