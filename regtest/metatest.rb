# encoding: utf-8
# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'regtest'
require 'tmpdir'

Dir.mktmpdir('regtest') do |tmpdir|
  Dir.chdir __dir__ do
    Dir['*.rb'].each do |filename|
      # beware of endless recursion
      next if filename =~ /metatest/
      FileUtils.cp filename, tmpdir
    end
  end
  Dir.chdir tmpdir do
    _, o, e = Open3.popen3("ruby -I #{File.join(__dir__, '../lib')} #{Dir['*.rb'].sort.join(' ')}")
    Regtest.sample 'metatest' do
      res = {'stdout' => o.read, 'stderr' => e.read}
      # levelling runtime specific values
      res['stdout'].gsub!(/\d+\.\d+/, 'x.xx')
      res
    end
  end
end
