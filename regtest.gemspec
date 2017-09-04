# -*- encoding: utf-8 -*-
# stub: regtest 1.1.0 ruby lib
#
# This file is automatically generated by rim.
# PLEASE DO NOT EDIT IT DIRECTLY!
# Change the values in Rim.setup in Rakefile instead.

Gem::Specification.new do |s|
  s.name = "regtest"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jan Friedrich"]
  s.date = "2017-09-04"
  s.description = "This library support a very simple way to do regression testing in Ruby\nprojects. You write Ruby scripts with samples. Run these and get the sample\nresults as YAML output besides your scripts. Check both the scripts and the YAML\nfiles with the results in you Source Code Control System. When you run the\nscrips on a later (or even previous) version of your code a simple diff show you\nif and how the changes in your code impact the results of your samples.\n\nThis is not a replacement for unit testing but a complement: You can produce a\nlot of samples with a small amount of Ruby code (e.g. a large number of\ncombinations of data).\n"
  s.email = "janfri26@gmail.com"
  s.files = ["./.aspell.pws", "Changelog", "Gemfile", "LICENSE", "README.md", "Rakefile", "lib/regtest", "lib/regtest.rb", "lib/regtest/colorize.rb", "lib/regtest/git.rb", "lib/regtest/task.rb", "regtest.gemspec", "regtest/combinations.rb", "regtest/combinations.yml", "regtest/example.rb", "regtest/example.yml", "regtest/filename with spaces.rb", "regtest/filename with spaces.yml", "regtest/metatest.rb", "regtest/metatest.yml", "regtest/no_samples.rb"]
  s.homepage = "https://github.com/janfri/regtest"
  s.licenses = ["Ruby"]
  s.rubygems_version = "2.6.13"
  s.summary = "Simple regression testing for Ruby projects."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<colorize>, ["~> 0.8"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rim>, ["~> 2.13"])
      s.add_development_dependency(%q<regtest>, ["~> 1.0"])
    else
      s.add_dependency(%q<colorize>, ["~> 0.8"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rim>, ["~> 2.13"])
      s.add_dependency(%q<regtest>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<colorize>, ["~> 0.8"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rim>, ["~> 2.13"])
    s.add_dependency(%q<regtest>, ["~> 1.0"])
  end
end
