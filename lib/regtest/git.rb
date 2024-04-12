# encoding: utf-8
# frozen_string_literal: true

require 'open3'

# Check if git is available
begin
  Open3.capture2e('git --version')
  module Regtest

    # Regtest plugin for git (results are checked automatically when running
    # regtest)
    module Git

      # Redefine Regtest.check_results.
      def check_results
        output_files = Regtest.results.keys
        if output_files.empty?
          report "\nNothing to do.", type: :success
          return :success
        end
        git_status = ['git', git_global_args, %w(status -s --)].flatten
        git_results, stderr, _ = Open3.capture3(*git_status, *output_files)
        unless stderr.empty?
          report "\ngit command coud not be executed!", type: :fail
          return :fail
        end
        case git_results
        when /^.M/ # at least one modified file
          report "\nThere are changes in your sample results!", type: :fail
          system *git_status, *output_files
          return :fail
        when /^.\?/ # at least one unknown file
          report "\nThere is at least one new sample result file.", type: :unknown_result
          system *git_status, *output_files
          return :unknown_result
        when '', /^. / # no changes in (maybe staged) files
          report "\nLooks good. :)", type: :success
          system *git_status, *output_files
          return :success
        else
          report "\nYour sample results are in a bad condition!", type: :fail
          system *git_status, *output_files
          return :fail
        end
      end

      class << self
        # git parameter +--work-tree+
        attr_accessor :work_tree

        # git parameter +--git-dir+
        attr_accessor :git_dir
      end

      private

      def git_global_args
        args = []
        if wt = Regtest::Git.work_tree
          args << format('--work-tree=%s', wt)
        end
        if gt = Regtest::Git.git_dir
          args << format('--git-dir=%s', gt)
        end
        args
      end

    end

    class << self
      prepend Git
    end

  end
rescue Errno::ENOENT
  warn 'git command not found: plugin regtest/git disabled'
end
