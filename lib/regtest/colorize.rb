# encoding: utf-8
# frozen_string_literal: true

module Regtest

  # Regtest plugin to have colorized reports.
  # It uses the great colorized gem
  # (see https://rubygems.org/gems/colorize)
  module Colorize

    @mapping = (%i(success fail unknown_result filename statistics).zip %i(green red yellow cyan default)).to_h

    class << self
      # Color mapping (all parameters of ColorizedString.colorize are supported
      # (see https://github.com/fazibear/colorize#usage)
      # Examples:
      #   Regtest::Colorize.mapping[:filename] = :light_blue
      #   Regtest::Colorize.mapping[:statistics] = {color: :cyan, mode: :italic}
      attr_accessor :mapping
    end

    begin
      require 'colorized_string'

      # Redefine Regtest.report.
      def report *args, type: nil
        color = Colorize.mapping[type]
        if color && $stdout.tty?
          args = args.map {|a| ColorizedString[a.to_s].colorize(color)}
        end
        puts *args
      end
    rescue LoadError
      warn 'gem colorize not found'
      warn 'plugin regtest/colorize disabled'
    end

  end

  class << self
    prepend Colorize
  end

end
