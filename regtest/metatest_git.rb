# encoding: utf-8
# frozen_string_literal: true

# If git isn't available skip this file
begin
  require 'open3'
  Open3.capture2e('git --version')

  require 'fileutils'
  require 'regtest'
  require 'regtest/git'
  require 'tmpdir'

  $my_dir = File.expand_path(__dir__)

  def create_sample name
    lib_dir = File.join($my_dir, '../lib')
    o, e, ps = Open3.capture3(*[{'NOREGTESTRC' => 'true'}, 'ruby', '-I', lib_dir, '-r', 'regtest/git'], *Dir['*.rb'].sort)
    Regtest.sample name do
      res = {'stdout' => o, 'stderr' => e}
      # Levelling out runtime specific differences.
      res['stdout'].gsub!(/\d+\.\d+/, 'x.xx')
      res['stdout'].gsub!(%r(\d+ samples/s), 'x samples/s')
      res['stdout'].gsub!(/^\?\? filename with spaces.yml$/m, '?? "filename with spaces.yml"')
      res['exitstatus'] = ps.exitstatus
      res
    end
  end

  def execute cmd
    Open3.capture2e cmd
  end

  NEW_SAMPLE = <<-END

  Regtest.sample 'new sample' do
    'new sample'
  end
  END

  Dir.mktmpdir('regtest') do |tmpdir|
    Dir.chdir $my_dir do
      Dir['*.rb'].each do |filename|
        # Beware of endless recursion.
        next if filename =~ /metatest/
        FileUtils.cp filename, tmpdir
      end
    end
    Dir.chdir tmpdir do
      execute 'git init'
      create_sample 'all new'
      execute 'git add *.rb examples.yml combinations.yml'
      create_sample 'only one new'
      example_rb = File.read('examples.rb')
      example_rb << NEW_SAMPLE
      File.write('examples.rb', example_rb)
      create_sample 'one new one modified to index'
      execute 'git commit -m "commit"'
      create_sample 'one new one modified'
      execute 'git add *.yml'
      create_sample 'all in index'
      execute 'git commit -m "commit"'
      create_sample 'all commited'
    end
  end
rescue Errno::ENOENT
end
