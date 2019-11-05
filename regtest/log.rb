# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

Regtest.sample 'test' do
  a = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  Regtest.log a
  b = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  Regtest.log b
  a < b
end
