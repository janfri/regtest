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
require 'set'
require 'yaml'

module Regtest

  extend self

  @start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  @results = {}
  @log_filenames = Set.new
  @exit_codes = Hash.new(1)
  @exit_codes.merge!({success: 0, unknown_result: 1, fail: 2})

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
    output_filename = Regtest.determine_filename_from_caller('.yml')
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
  # By default the log file is truncated at the first call of Regtest.log for
  # each run of regtest, and all following calls appends to the log file. So
  # you have a log for one run of regtest. You can use mode ('a' or 'w') to
  # change this behaviour for each call of Regtest.log.
  def log s, mode: nil
    log_filename = Regtest.determine_filename_from_caller('.log')
    case mode
    when nil
      mode = Regtest.log_filenames.include?(log_filename) ? 'a' : 'w'
    when 'a', 'w'
      # ok
    else
      raise ArgumentError.new(format('Mode %s is not allowed.', mode))
    end
    Regtest.log_filenames << log_filename
    File.open log_filename, mode do |f|
      f.puts s
    end
  end

  class << self

    attr_reader :exit_codes, :log_filenames, :results, :start

    # Determine a filename which is derived from the filename of the "real"
    # caller of the calling method
    # @param ext new extension (i.e. '.yml')
    def determine_filename_from_caller ext
      cls = caller_locations
      base_label = cls.first.base_label
      cls = cls.drop_while {|cl| cl.base_label == base_label}
      cls.first.path.sub(/\.rb$/, '') << ext.to_s
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
