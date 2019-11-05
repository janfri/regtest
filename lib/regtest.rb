# encoding: utf-8
# frozen_string_literal: true
#
# Regtest - Simple Regression Testing With Ruby
#
# Copyright 2014, 2015, 2017-2019 by Jan Friedrich <janfri26@gmail.com>
# License: Regtest is licensed under the same terms as Ruby itself.
#

require 'ostruct'
require 'regtest/version'
require 'yaml'

module Regtest

  @start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  @results = {}
  @exit_codes = Hash.new(1)
  @exit_codes.merge!({success: 0, unknown_result: 1, fail: 2})

  class << self

    attr_reader :exit_codes, :results, :start

    # Define a sample
    def sample name
      h = {}
      name = name.to_s if name.kind_of?(Symbol)
      h['sample'] = name
      begin
        h['result'] = yield
      rescue Exception => e
        h['exception'] = e.message
      end
      output_filename = determine_output_filename
      unless Regtest.results[output_filename]
        Regtest.report "\n", type: :filename unless Regtest.results.empty?
        Regtest.report output_filename, type: :filename
        Regtest.results[output_filename] = []
      end
      Regtest.results[output_filename] << h
      print '.'; $stdout.flush
      h
    end

    # Build all combinations of a Hash-like object with arrays as values.
    # Return value is an array of OpenStruct instances.
    #
    # Example:
    #   require 'ostruct'
    #   require 'regtest'
    #
    #   o = OpenStruct.new
    #   o.a = [1,2,3]
    #   o.b = [:x, :y]
    #   Regtest.combinations(o)
    #   # => [#<OpenStruct a=1, b=:x>, #<OpenStruct a=1, b=:y>,
    #   #     #<OpenStruct a=2, b=:x>, #<OpenStruct a=2, b=:y>,
    #   #     #<OpenStruct a=3, b=:x>, #<OpenStruct a=3, b=:y>]
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

    # Write (temporary) informations to a log file
    def log s
      if @log_filename != determine_log_filename || !@log_file
        @log_filename = determine_log_filename
        @log_file.close if @log_file
        @log_file = File.open(determine_log_filename, 'w')
      end
      @log_file.puts s
    end

    # Determine the filename of the sample file
    # with informations from caller
    def determine_sample_filename
      rest = caller.drop_while {|c| c !~ /in `sample'/}.drop_while {|c| c =~ /in `sample'/}
      rest.first.split(/:\d+:/).first
    end

    # Determine the filename of the ouput file (results file)
    # with informations from caller
    def determine_output_filename
      determine_sample_filename.split(/:\d+:/).first.sub(/\.rb/, '') << '.yml'
    end

    # Determine the filename of the log file (for temporary outputs)
    # with informations from caller
    def determine_log_filename
      determine_sample_filename.split(/:\d+:/).first.sub(/\.rb/, '') << '.log'
    end

    # Report some statistics, could be overwritten by plugins.
    def report_statistics
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      time = now - start
      sample_count = results.values.map(&:size).reduce(0, &:+)
      report format("\n\n%d samples executed in %.2f s (%d samples/s)", sample_count, time, sample_count / time), type: :statistics
    end

    # Save all results to the corresponding files.
    def save
      results.each_pair do |filename, arr|
        File.open(filename, 'w') do |f|
          arr.each do |h|
            f.write h.to_yaml
          end
        end
      end
    end

    # Checking results, should be overwritten by SCM plugins
    # e.g. regtest/git
    # @return Symbol with check result (one of :success, :unknown_result or :fail)
    def check_results
      report "\nPlease check result files manually. Regtest isn't able to do that.", type: :unknown_result
      :unknown_result
    end

    # Report text to output with possible type, could be overwritten
    # by plugins e.g. regtest/colors.
    def report *args, type: nil
      puts *args
    end
  end

end

# Load .regtestrc from home directory and actual directory if exists
# and ENV['NOREGTESTRC'] is not set.
unless ENV['NOREGTESTRC']
  Dir[File.join(Dir.home, '.regtestrc'), '.regtestrc'].each {|fn| load fn}
end

at_exit do
  ARGV.each {|a| load a}
  Regtest.save
  Regtest.report_statistics
  check_state = Regtest.check_results
  exit Regtest.exit_codes[check_state]
end
