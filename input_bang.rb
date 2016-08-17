require './input_bang_base'

module MSSP

  class InputBang < InputBangBase

    def fill_with source ; @source = source.id ; end
    def is_filled? ; @source != nil ; end

    def clear
      if is_filled?
        ## clear in the output
        source.remove_output self
      end

      ## clear here
      remove_source
      clear_links
    end

    def source
      if is_filled?
        from_engine @source
      else
        nil
      end
    end

    def remove boite
      remove_source
    end

    def remove_source
      source.remove_output self if @source != nil
      @source = nil
      clear_links
    end

  end

end
