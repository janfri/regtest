desc 'Run regression tests'
task :regtest do
  filenames = FileList.new('regtest/*.rb')
  sh "ruby -I lib #{filenames.join(' ')}"
end
