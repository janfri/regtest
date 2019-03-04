# encoding: utf-8
# frozen_string_literal: true

# Regtest sample files (= Ruby files)
REGTEST_FILES_RB = FileList.new('regtest/**/*.rb')

# ALL Regtest files (sample files, results files and maybe other files)
REGTEST_FILES = FileList.new('regtest/**/*').select {|fn| File.file?(fn)}

desc 'Run regression tests'
task :regtest do
  sh *%w(ruby -I lib:regtest), *REGTEST_FILES_RB
end
