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
  File.readlines($log_filename, chomp: true)
end

Regtest.sample 'first log entry appends to file' do
  Regtest.log 'first log entry', mode: 'a'
  lines_of_log_file
end

Regtest.sample 'second log entry appends to file' do
  Regtest.log 'second log entry'
  lines_of_log_file
end

Regtest.sample 'third log entry appends to file' do
  Regtest.log 'first log entry', mode: 'a'
  lines_of_log_file
end
