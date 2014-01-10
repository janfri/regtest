desc 'Run regression tests'
task :regtest do
  filenames = FileList.new('regtest/*.rb')
  sh "ruby #{filenames.join(' ')}"
end
