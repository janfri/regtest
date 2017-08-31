# encoding: utf-8
# frozen_string_literal: true

begin
  require 'colorized_string'

  module Regtest

    module Colorize

      # Color mapping (you can change it via Regtest.colors)
      @colors = (%i(success fail unknown_result filename statistics).zip %i(green red yellow cyan default)).to_h

      # Redefine Regtest.report
      def report *args, type: nil
        color = Colorize.colors[type]
        if color && $stdout.tty?
          args = args.map {|a| ColorizedString[a.to_s].colorize(color)}
        end
        puts *args
      end

      class << self
        attr_reader :colors
      end

    end

    class << self
      prepend Colorize
    end

  end
rescue LoadError
  warn 'gem colorize not found'
  warn 'plugin regtest/colorize disabled'
end
