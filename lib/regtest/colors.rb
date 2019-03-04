# encoding: utf-8
# frozen_string_literal: true

module Regtest

  module Colors

    # Redefine Regtest.report
    def report *args, type: nil
      color = Colors.mapping[type]
      if color && $stdout.tty?
        args = args.map {|a| Colors.apply(a.to_s, color)}
      end
      puts *args
    end

    class << self
      # Color mapping
      # Examples:
      #   Regtest::Colors.mapping[:filename] = :lightblue
      #   Regtest::Colors.mapping[:fail] = :@red # '@' prefix means background color
      #   Regtest::Colors.mapping[:statistics] = %i(cyan italic) # more than one color code is possible
      attr_accessor :mapping

      # Apply color codes to a string
      def apply str, *codes
        codes.flatten.each do |c|
          num = @codes[c.to_sym]
          fail format('Code %s not supported.', c) unless num
          str = format("\e[%dm%s", num, str)
        end
        format("%s\e[0m", str)
      end

      # Get available color codes
      def codes
        @codes.keys
      end
    end

    private

    @mapping = (%i(success fail unknown_result filename).zip %i(green red yellow blue)).to_h
    @codes = {}

    %i(bold faint italic underline).each_with_index do |mode, i|
      @codes[mode] = 1 + i
    end

    %i(black red green yellow blue magenta cyan white).each_with_index do |color, i|
      @codes[color] = 30 + i
      @codes[format('@%s', color).to_sym] = 40 + i
      @codes[format('light%s', color).to_sym] = 90 + i
      @codes[format('@light%s', color).to_sym] = 100 + i
    end

  end

  class << self
    prepend Colors
  end

end
