# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

$yml_filename = __FILE__.sub(/\.rb$/, '.yml')

Regtest.sample 'spaces in filenames' do
  format('If you can read this in the results file "%s" then regtest can handle filenames with spaces. :)', File.basename($yml_filename))
end
