# encoding: utf-8
# frozen_string_literal: true

$:.unshift 'lib'

require 'rim/tire'
require 'rim/version'

require 'regtest/task'
require 'regtest/version'

Rim.setup do |p|
end

# JRuby does not support escaping of filenames with spaces in Open3.capture3
# therefore ignore metatest files when running on JRuby
if RUBY_ENGINE == 'jruby'
  REGTEST_FILES_RB.reject! {|fn| fn =~ /metatest/}
end

task :before_regtest do
  verbose false do
    temp_files = FileList.new('regtest/*.{log,yml}')
    temp_files.each {|fn| rm fn}
  end
end

task :regtest => :before_regtest
task :test => :regtest
task :default => :test
