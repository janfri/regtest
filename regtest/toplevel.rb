# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

methods_before = methods

extend Regtest

methods_after = methods

Regtest.sample "Toplevel methods defined by 'extend Regtest'" do
  (methods_after - methods_before).map(&:to_s).sort
end

Regtest.sample 'metatest' do
  sample 'sample works at toplevel' do
    true
  end
end

Regtest.sample 'combinations work at toplevel' do
  combinations(x: %w(a b), y: [1,2]).map(&:to_h)
end

Regtest.sample 'log works at toplevel' do
  f = rand.to_s
  log f
  File.read(__FILE__.sub(/\.rb$/, '.log')).chomp == f
end
