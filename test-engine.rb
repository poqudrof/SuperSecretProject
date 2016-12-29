require 'jruby_art'
require 'jruby_art/app'
require 'jruby/core_ext'

require_relative 'window'
require_relative 'engine'
require_relative 'boite'
require 'skatolo'

lib = "/home/jiii/repos/SuperSecretProject/boites/"
work = "/home/jiii/repos/SuperSecretProject/testBoites/"

engine = MSSP::Engine.new(work, lib)
engine.load_program "test0.yaml";

engine.run

# while true do
#   puts "running..."
#   engine.run
#   sleep(0.05)
# end
