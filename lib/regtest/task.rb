# encoding: utf-8
# frozen_string_literal: true
#
# Copyright 2014, 2016 by Jan Friedrich <janfri26@gmail.com>
# License: Regtest is licensed under the same terms as Ruby itself.
#

REGTEST_FILES_RB = FileList.new('regtest/**/*.rb')
REGTEST_FILES_YML = FileList.new('regtest/**/*.yml')
REGTEST_FILES = REGTEST_FILES_RB + REGTEST_FILES_YML

desc 'Run regression tests'
task :regtest do
  sh "ruby -I lib:regtest #{REGTEST_FILES_RB}"
end
