# encoding: utf-8
# frozen_string_literal: true

$:.unshift 'lib'

require 'rim/tire'
require 'rim/regtest'
require 'rim/version'

require 'regtest/task'

Rim.setup do |p|
  p.name = 'regtest'
  p.version = '1.1.0'
  p.authors = 'Jan Friedrich'
  p.email = 'janfri26@gmail.com'
  p.summary = 'Simple regression testing for Ruby projects.'
  p.license = 'Ruby'
  p.description = <<-END.gsub(/^ +/, '')
    This library support a very simple way to do regression testing in Ruby
    projects. You write Ruby scripts with samples. Run these and get the sample
    results as YAML output besides your scripts. Check both the scripts and the YAML
    files with the results in you Source Code Control System. When you run the
    scrips on a later (or even previous) version of your code a simple diff show you
    if and how the changes in your code impact the results of your samples.

    This is not a replacement for unit testing but a complement: You can produce a
    lot of samples with a small amount of Ruby code (e.g. a large number of
    combinations of data).
  END
  p.homepage = 'https://github.com/janfri/regtest'
end

task :test do
  # nothing
end
