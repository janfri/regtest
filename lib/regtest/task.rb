REGTEST_FILES = FileList.new('regtest/**/*.rb')

desc 'Run regression tests'
task :regtest do
  sh "ruby -I lib:regtest #{REGTEST_FILES}"
end
