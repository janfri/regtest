# encoding: utf-8
# frozen_string_literal: true

require 'regtest'
require 'fileutils'


$log_filename = __FILE__.sub(/\.rb$/, '.log')

# set the initial content of the log file
File.open($log_filename, 'w') do |f|
  f.puts 'initial line'
end

def lines_of_log_file
  File.readlines($log_filename).map(&:chomp) # keyword chomp is not supported by Ruby versions < 2.4
end

Regtest.sample 'first log entry rewrites log file' do
  Regtest.log 'first log entry'
  lines_of_log_file
end

Regtest.sample 'second log entry rewrites log file' do
  Regtest.log 'second log entry', mode: 'w'
  lines_of_log_file
end

Regtest.sample 'third log entry rewrites log file' do
  Regtest.log 'third log entry', mode: 'w'
  lines_of_log_file
end
