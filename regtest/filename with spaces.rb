# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

Regtest.sample 'spaces in filenames' do
  "If you can read this in the results file #{File.basename(__FILE__.sub(/\.rb/, '.yml')).inspect} then regtest can handle filenames with spaces. :)"
end
