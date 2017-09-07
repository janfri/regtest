# encoding: utf-8
# frozen_string_literal: true

require 'open3'

# Check if git is available and current directory is part of a git repository.
begin
  _, p = Open3.capture2e('git status --porcelain')
  if p.exitstatus == 0
    module Regtest

      module Git

        # Redefine Regtest.check_results.
        def check_results
          output_files = Regtest.results.keys
          if output_files.empty?
            report "\nNothing to do.", type: :success
            return :success
          end
          git_stat, _, _ = Open3.capture3(*%w(git status --porcelain --), *output_files)
          case git_stat
          when ''
            report "\nLooks good. :)", type: :success
            return :success
          when /^.M/ # modified file
            report "\nThere are changes in your sample results!", type: :fail
            system *%w(git status -s --), *output_files
            return :fail
          when /^.\?/ # unknown file
            report "\nThere are new sample result files. Please check them manually.", type: :unknown_result
            system *%w(git status -s --), *output_files
            return :unknown_result
          else
            report "\nYour sample results are in a bad condition!", type: :fail
            system *%w(git status -s --), *output_files
            return :fail
          end
        end

      end

      class << self
        prepend Git
      end

    end
  else
    warn 'current directory is not part of a git repository:'
    warn 'plugin regtest/git disabled'
  end
rescue Errno::ENOENT
  warn 'git command not found: plugin regtest/git disabled'
end
