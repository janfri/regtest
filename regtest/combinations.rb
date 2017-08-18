# encoding: utf-8
# frozen_string_literal: true

require 'ostruct'
require 'regtest'

o = OpenStruct.new
o.a = [1, 2, 3]
o.b = [:x, :y]

Regtest.combinations(o).each_with_index do |c, i|
  Regtest.sample "Combination #{i}" do
    c.to_h
  end
end
