require 'yaml'
require 'fileutils'

module MSSP

  def from_engine boite ; $engine.boites[boite] ; end

  class Engine
    attr_reader :links, :boites, :to_delete
    attr_reader :working_directory, :library_directory

    def initialize work_dir, lib_dir
      @boites = {}
      @to_delete = []

      $engine = self
      ## HACKS, TODO: load properly
      @library_directory = lib_dir
      @working_directory = work_dir
    end

    def encode_with encoder
      encoder['boites'] = @boites
    end

    def fork_boite boite
      inside_core_name = core_name boite.name
      generated_name = generated_name boite.name, boite.id

      if not File.exists? inside_core_name
        puts "ERROR - CORE file not found: " + boite.name
        return
      end

      FileUtils.copy inside_core_name, generated_name

      return generated_name
    end

    def core_name name
      @library_directory + "core/" + name + ".rb"
    end

    def app_name name
      @working_directory + name + ".rb"
    end

    def generated_name name, id
      @working_directory + "generated_boites/" + name + "--"+ id.to_s + ".rb"
    end

    def find_file boite
      name = boite.name

      inside_core_name = core_name name
      inside_app_name = app_name name
      generated_name = generated_name name, boite.id

      puts inside_app_name

      return [inside_app_name, true] if File.exists? inside_app_name
      return [inside_core_name, false] if File.exists? inside_core_name
      return [generated_name, true] if File.exists? generated_name

      ## nothing found, return inside app
      ## it should be a voluntary act of creation.
      [inside_app_name, true]
    end

    def run
      @to_delete.each do |boite|
        boite.delete_inside
        remove boite
      end
      @to_delete.clear

      @boites.each_value { |boite| boite.update_global }
    end

    def remove_all
      @boites.each_value do |boite|
        boite.delete
      end

      @boites.each_value do |boite|
        remove boite
      end
    end

    def load_program file_name
      begin
        file = File.read(file_name)
        other_boites = YAML.load(file)
        other_boites.each_value {|b| add b}
      rescue
        puts "Error loading: " + file_name
      end
    end

    def save_program file_name
      File.open(file_name, 'w') { |f| f.write YAML.dump(@boites) }
    end

    def remove boite
      @boites.delete boite.id
    end

    def add boite
      @boites[boite.id] = boite
    end


    ############## Tests.... #####
    def test
      save_program 'test2.yaml'
      ## read
      out = test2
      test_reload out
      ## save again
      test_save 'test3.yaml', out
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
