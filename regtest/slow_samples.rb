# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

1.upto 10 do |i|
  Regtest.sample "Slow sample #{i}" do
    sleep rand(0..0.05)
    nil
  end
end

Regtest.sample 'Slowest sample' do
  sleep 0.2
  nil
end
