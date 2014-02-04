#
# Regtest - Regression testing for Ruby
#
# Copyright 2014 by Jan Friedrich (janfri26@gmail.com)
# License: Rubys License
#

require 'yaml'

module Regtest

  @count = 0
  @results = {}
  @start = Time.now

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
    unless Regtest.results[output_filename]
      puts unless Regtest.results.empty?
      puts File.basename(output_filename, '.yml')
      Regtest.results[output_filename] = []
    end
    Regtest.results[output_filename] << h
    Regtest.count += 1
    print '.'; $stdout.flush
  end

  class << self
    attr_accessor :count, :results, :start
  end

  module_function :sample

end

at_exit do
  ARGV.each {|a| load a}
  sample_count = Regtest.count
  sample_time = Time.now - Regtest.start
  puts format("\n\n%d samples executed in %.2f s (%.2f samples/s)", sample_count, sample_time, sample_count / sample_time)
  save_start = Time.now
  Regtest.results.each_pair do |filename,arr|
    File.open(filename, 'w') do |f|
      arr.each do |h|
        f.write h.to_yaml
      end
    end
  end
  files_count = Regtest.results.size
  save_time = Time.now - save_start
  puts format("%d files written in %.2f s (%.2f files/s)", files_count, save_time, files_count / save_time)
end
