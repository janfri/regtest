# encoding: utf-8
# frozen_string_literal: true
#
# Regtest - Simple Regression Testing For Ruby Projects
#
# Copyright 2014, 2015 by Jan Friedrich <janfri26@gmail.com>
# License: Regtest is licensed under the same terms as Ruby itself.
#

require 'ostruct'
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
      puts output_filename
      Regtest.results[output_filename] = []
    end
    Regtest.results[output_filename] << h
    Regtest.count += 1
    print '.'; $stdout.flush
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
    attr_accessor :count, :results, :start

    def report_and_save
      time = Time.now - start
      puts format("\n\n%d samples executed in %.2f s (%.2f samples/s)", count, time, count / time)
      results.each_pair do |filename, arr|
        File.open(filename, 'w') do |f|
          arr.each do |h|
            f.write h.to_yaml
          end
        end
      end
    end
  end

  module_function :sample, :combinations

end

at_exit do
  ARGV.each {|a| load a}
  Regtest.report_and_save
end
