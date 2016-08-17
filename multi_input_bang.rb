require './input_bang_base'

module MSSP

  class MultiInputBang < InputBangBase
    include MSSP

    def initialize boite
      super(boite, "multi_input", -1)
      @sources = []
    end

    def sources ; @sources.map {|s| from_engine s} ; end
    def add_source source ; @sources << source ; end

    def remove boite
      remove_from_sources boite
    end

    def remove_from_sources boite
      boite.remove_output self
      @sources.delete boite.id

      @links.delete_if do |link|
        link.out_boite == boite
      end
    end

    def remove_all_sources
      sources.each do |source|
        source.remove_output self
      end
      @sources.clear
      clear_links
    end

  end
end
