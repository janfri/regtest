# encoding: utf-8
# frozen_string_literal: true
#
# Copyright 2014, 2016, 2017 by Jan Friedrich <janfri26@gmail.com>
# License: Regtest is licensed under the same terms as Ruby itself.
#

# Regtest sample files (= Ruby files)
REGTEST_FILES_RB = FileList.new('regtest/**/*.rb')

# ALL Regtest files (sample files, results files and maybe other files)
REGTEST_FILES = REGTEST_FILES_RB.map {|fn| Dir[fn.sub(/\.rb/, '.*')]}.flatten.sort

desc 'Run regression tests'
task :regtest do
  sh *%w(ruby -I lib:regtest), *REGTEST_FILES_RB
end
