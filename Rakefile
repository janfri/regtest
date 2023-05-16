# encoding: utf-8
# frozen_string_literal: true

$:.unshift 'lib'

require 'rim/tire'
require 'rim/regtest'
require 'rim/version'

require 'regtest/task'
require 'regtest/version'

Rim.setup do |p|
  p.name = 'regtest'
  p.version = Regtest::VERSION
  p.authors = 'Jan Friedrich'
  p.email = 'janfri26@gmail.com'
  p.summary = 'Simple regression testing with Ruby.'
  p.license = 'Ruby'
  p.description = <<-END.gsub(/^ +/, '')
    This library supports a very simple way to do regression testing with Ruby. It
    is not limited to Ruby projects you can use it also in other contexts where you
    can extract data with Ruby.

    You write Ruby scripts with samples. Run these and get the sample results as
    results files besides your scripts. Check both the scripts and the results
    files in you Source Code Management System (SCM). When you run the scrips on a
    later (or even previous) version of your code a simple diff show you if and how
    the changes in your code or environment impact the results of your samples.

    This is not a replacement for unit testing but a complement: You can produce a
    lot of samples with a small amount of Ruby code (e.g. a large number of
    combinations of data).
  END
  p.homepage = 'https://github.com/janfri/regtest'
  p.ruby_version = '>=2.1.0'
end

# JRuby does not support escaping of filenames with spaces in Open3.capture3
# therefore ignore metatest files when running on JRuby
if RUBY_ENGINE == 'jruby'
  REGTEST_FILES_RB.reject! {|fn| fn =~ /metatest/}
end

task :before_regtest do
  verbose false do
    rm_rf 'regtest/*.log'
    rm_rf 'regtest/*.yml'
  end
end

task :regtest => :before_regtest
task :test => :regtest
task :default => :test
