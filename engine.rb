require 'yaml'

module MSSP

  def from_engine boite ; $engine.boites[boite] ; end

  class Engine
    attr_reader :links, :boites
    attr_reader :working_directory, :library_directory

    def initialize work_dir, lib_dir
      @boites = {}

      $engine = self
      ## HACKS, TODO: load properly
      @library_directory = lib_dir
      @working_directory = work_dir
    end

    def encode_with encoder
      encoder['boites'] = @boites
    end

    def find_file name

      inside_core_name = @library_directory + "core/" + name + ".rb"
      inside_app_name = @working_directory +  name + ".rb"

      return [inside_app_name, true] if File.exists? inside_app_name
      return [inside_core_name, false] if File.exists? inside_core_name

      ## nothing found, return inside app
      [inside_app_name, true]
    end

    def run
      @boites.each_value { |boite| boite.update_global }
    end

    def remove boite
      @boites.delete boite.id
    end

    def remove_all
      @boites.each_value do |boite|
        boite.delete
      end

      @boites.each_value do |boite|
        remove boite
      end
    end

    def add boite
      @boites[boite.id] = boite
    end

    def test
      test_save 'test2.yaml', @boites

      ## read
      out = test2

      test_reload out

      ## save again
      test_save 'test3.yaml', out
    end

    def load file_name
      file = File.read(file_name)
      other_boites = YAML.load(file)
      other_boites.each_value {|b| add b}
    end

    def test_reload other_boites
      remove_all
      other_boites.each_value {|b| add b}
    end

    def test_save name, room
      File.open(name, 'w') { |f| f.write YAML.dump(room) }
    end

    def test2
      file = File.read('test2.yaml')
      boites2 = YAML.load(file)

      boites2
    end

  end
end
