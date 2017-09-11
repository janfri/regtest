# encoding: utf-8
# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'regtest'
require 'tmpdir'

Dir.mktmpdir('regtest') do |tmpdir|
  Dir.chdir __dir__ do
    Dir['*.rb'].each do |filename|
      # Beware of endless recursion.
      next if filename =~ /metatest/
      FileUtils.cp filename, tmpdir
    end
  end
  Dir.chdir tmpdir do
    lib_dir = File.join(__dir__, '../lib')
    o, e, ps = Open3.capture3(*[{'NOREGTESTRC' => 'true'}, 'ruby', '-I', lib_dir], *Dir['*.rb'].sort)
    Regtest.sample 'metatest' do
      res = {'stdout' => o, 'stderr' => e}
      # Levelling out runtime specific differences.
      res['stdout'].gsub!(/\d+\.\d+/, 'x.xx')
      res['exitstatus'] = ps.exitstatus
      res
    end
  end
end
