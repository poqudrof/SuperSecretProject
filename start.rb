# -*- coding: utf-8 -*-

## To add in sketches
## Processing::App::SKETCH_PATH = __FILE__
## class Sketch < Processing::App

require 'ruby-processing' 

### Version 1

# add the current folder to the ruby path.
# $:.unshift File.dirname(__FILE__)

require 'jruby/core_ext'

require './cp5.rb'
require './project.rb'
# Sketch.new


## Version 2

## ---------------------
# require 'ruby-processing' 
# runner = Processing::Runner.new
# runner.parse_options(['live', 'sketch1.rb'])
# runner.execute!
