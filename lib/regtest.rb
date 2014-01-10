#
# Regtest - Regression testing for Ruby
#
# Copyright 2014 by Jan Friedrich (janfri26@gmail.com)
# License: Rubys License
#

require 'yaml'

module Regtest

  @@results = {}

  def sample name
    h = {}
    name = name.to_s if name.kind_of?(Symbol)
    h['sample'] = name
    begin
      h['result'] = yield
    rescue Exception => e
      h['exception'] = e.message
    end
    output_filename = caller.first.split(/:/).first.sub(/\.rb/, '') << '.yml'
    unless @@results[output_filename]
      puts unless @@results.empty?
      puts File.basename(output_filename, '.yml')
      @@results[output_filename] = []
    end
    @@results[output_filename] << h
    print '.'; $stdout.flush
  end

  def self.results
    @@results
  end

  module_function :sample

end

at_exit do
  ARGV.each {|a| load a}
  puts
  Regtest.results.each_pair do |filename,arr|
    File.open(filename, 'w') do |f|
      arr.each do |h|
        f.write h.to_yaml
      end
    end
  end
end
