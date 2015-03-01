require 'ruby-processing' 

## Set sketch Path to access data & stuff
Processing::App::SKETCH_PATH = "/home/jiii/rp_samples/Example-Sketches-1.4/samples/external_library/java_processing/peasy_cam/"

##  Add the current folder to the Ruby Path. 
$:.unshift File.dirname(__FILE__)

# Work with java. 
require 'java' 
