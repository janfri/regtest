# encoding: utf-8
# frozen_string_literal: true
#
# Regtest - Simple Regression Testing For Ruby Projects
#
# Copyright 2014, 2015, 2017 by Jan Friedrich <janfri26@gmail.com>
# License: Regtest is licensed under the same terms as Ruby itself.
#

require 'ostruct'
require 'yaml'

module Regtest

  @start = Time.now
  @results = {}
  @statistics = []

  def sample name
    start = Time.now
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
      puts nil, type: :filename unless Regtest.results.empty?
      puts output_filename, type: :filename
      Regtest.results[output_filename] = []
    end
    Regtest.results[output_filename] << h
    print '.'; $stdout.flush
    stop = Time.now
    @statistics << OpenStruct.new(filename: output_filename, sample: name, time: stop - start)
    name
  end

  # Build all combinations of a Hash-like object with arrays as values.
  # Return value is an array of OpenStruct instances.
  #
  # Example:
  #   require 'ostruct'
  #   o = OpenStruct.new
  #   o.a = [1,2,3]
  #   o.b = [:x, :y]
  #   Regtest.combinations(o).map(&:to_h) # => [{:a=>1, :b=>:x}, {:a=>1, :b=>:y}, {:a=>2, :b=>:x}, {:a=>2, :b=>:y}, {:a=>3, :b=>:x}, {:a=>3, :b=>:y}]
  #
  def combinations hashy
    h = hashy.to_h
    a = h.values[0].product(*h.values[1..-1])
    res = []
    a.each do |e|
      o = OpenStruct.new
      h.keys.zip(e) do |k, v|
        o[k] = v
      end
      res << o
    end
    res
  end

  class << self
    attr_reader :results, :statistics, :start

    def report
      time = Time.now - start
      sample_count = statistics.size
      puts format("\n\n%d samples executed in %.2f s (%.2f samples/s)", sample_count, time, sample_count / time), type: :statistics
    end

    def save
      results.each_pair do |filename, arr|
        File.open(filename, 'w') do |f|
          arr.each do |h|
            f.write h.to_yaml
          end
        end
      end
    end

    # Checking results, should be overwritten in SCM plugins
    # e.g. regtest/git
    def check_results
      puts "\nPlease check results manually. Regtest isn't able to do that.", type: :unknown_result
    end

    # Redefine print and puts with an additional type parameter to support colorizing in plugins
    %w(print puts).each do |name|
      define_method name do |*args, type: nil|
        super *args
      end
    end
  end

  module_function :sample, :combinations

end

# Load .regtestrc from home directory and actual directory if exists
# and ENV['NOREGTESTRC'] is not set
unless ENV['NOREGTESTRC']
  Dir[File.join(Dir.home, '.regtestrc'), '.regtestrc'].each {|fn| load fn}
end

at_exit do
  ARGV.each {|a| load a}
  Regtest.report
  Regtest.save
  Regtest.check_results
end
