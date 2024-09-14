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
    o, e, ps = Open3.capture3(*[{'NOREGTESTRC' => 'true'}, 'ruby', '-I', lib_dir, '-r', 'regtest', '-r', 'regtest/git'], *Dir['work_tree/*.rb'].sort)
    Regtest.sample name do
      res = {'stdout' => o, 'stderr' => e}
      # Levelling out runtime specific differences.
      res['stdout'].gsub!(/\d+\.\d+/, 'x.xx')
      res['stdout'].gsub!(%r(\d+ samples/s), 'x samples/s')
      res['exitstatus'] = ps.exitstatus
      res
    end
  end

  def run_samples work_tree_dir, git_dir
    create_sample 'without --work-tree and without --git-dir'
    File.write File.join(work_tree_dir, 'init.rb'), "Regtest::Git.work_tree = '#{work_tree_dir}'"
    create_sample 'with --work-tree and without --git-dir'
    File.write File.join(work_tree_dir, 'init.rb'), "Regtest::Git.git_dir = '#{git_dir}'"
    create_sample 'without --work-tree and with --git-dir'
    File.write File.join(work_tree_dir, 'init.rb'), "Regtest::Git.work_tree = '#{work_tree_dir}'; Regtest::Git.git_dir = '#{git_dir}'"
    create_sample 'with --work-tree and with --git-dir'
    File.write File.join(work_tree_dir, 'init.rb'), "Regtest::Git.C = '#{work_tree_dir}'"
    create_sample 'with -C'
  end

  def execute cmd
    Open3.capture2e cmd
  end

  SAMPLE = <<-END
  Regtest.sample 'sample' do
    'sample result'
  end
  END

  Dir.mktmpdir('regtest') do |tmpdir|
    Dir.chdir tmpdir do
      work_tree_dir = File.join(tmpdir, 'work_tree')
      git_dir = File.join(work_tree_dir, '.git')
      FileUtils.mkdir work_tree_dir
      Dir.chdir work_tree_dir do
        File.write('sample.rb', SAMPLE)
        execute 'git init'
        execute 'git add sample.rb'
      end
      run_samples work_tree_dir, git_dir
    end
  end
rescue Errno::ENOENT
end
