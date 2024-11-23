# encoding: utf-8
require_relative 'lib/regtest/version'

Gem::Specification.new do |s|
  s.name = 'regtest'
  s.version = Regtest::VERSION

  s.author = 'Jan Friedrich'
  s.email = 'janfri26@gmail.com'

  s.summary = 'Simple regression testing with Ruby.'
  s.description = <<~END
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
  s.homepage = 'https://github.com/janfri/regtest'

  s.license = 'Ruby'

  s.require_path = 'lib'
  s.files = %w[Changelog LICENSE README.md] + Dir['lib/**/*']

  s.required_ruby_version = '>= 2.1.0'

  s.add_development_dependency 'rake', '>= 0'
  s.add_development_dependency 'rim', '~> 3.0'
end
