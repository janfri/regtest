# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

$log_filename = __FILE__.sub(/\.rb$/, '.log')

def cleaned_lines_of_log_file
  File.readlines($log_filename).map {|l| l.chomp.gsub(/\d+/, '#')}
end

Regtest.sample 'logging inside of a sample' do
  a = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  Regtest.log a
  b = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  Regtest.log b
  cleaned_lines_of_log_file
end

Regtest.sample 'invalid mode' do
  Regtest.log 'foo', mode: 'x'
end

Regtest.log 'Logging from outside of a sample works.'

Regtest.sample 'check final log file' do
  cleaned_lines_of_log_file
end
