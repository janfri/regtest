# -*- encoding: utf-8 -*-
# stub: regtest 2.4.0 ruby lib
#
# This file is automatically generated by rim.
# PLEASE DO NOT EDIT IT DIRECTLY!
# Change the values in Rim.setup in Rakefile instead.

Gem::Specification.new do |s|
  s.name = "regtest"
  s.version = "2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jan Friedrich"]
  s.date = "2024-09-13"
  s.description = "This library supports a very simple way to do regression testing with Ruby. It\nis not limited to Ruby projects you can use it also in other contexts where you\ncan extract data with Ruby.\n\nYou write Ruby scripts with samples. Run these and get the sample results as\nresults files besides your scripts. Check both the scripts and the results\nfiles in you Source Code Management System (SCM). When you run the scrips on a\nlater (or even previous) version of your code a simple diff show you if and how\nthe changes in your code or environment impact the results of your samples.\n\nThis is not a replacement for unit testing but a complement: You can produce a\nlot of samples with a small amount of Ruby code (e.g. a large number of\ncombinations of data).\n"
  s.email = "janfri26@gmail.com"
  s.files = ["./.aspell.pws", "Changelog", "Gemfile", "LICENSE", "README.md", "Rakefile", "lib/regtest", "lib/regtest.rb", "lib/regtest/colors.rb", "lib/regtest/git.rb", "lib/regtest/task.rb", "lib/regtest/version.rb", "regtest.gemspec"]
  s.homepage = "https://github.com/janfri/regtest"
  s.licenses = ["Ruby"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0")
  s.rubygems_version = "3.6.0.dev"
  s.summary = "Simple regression testing with Ruby."

  s.specification_version = 4

  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<rim>, ["~> 2.17"])
end
