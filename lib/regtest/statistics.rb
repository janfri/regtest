# encoding: utf-8
# frozen_string_literal: true

require 'io/console'
require 'regtest'

begin
  module Regtest

    module Statistics

      @histogram_slots = 0
      @percentiles = []
      @slow_sample_count = 0
      @statistics = []

      class << self
        attr_reader :statistics
        attr_accessor :histogram_slots, :percentiles, :slow_sample_count
      end

      require 'descriptive-statistics'
      # If loading of descriptive-statistics fails the accessor above is
      # available in .regtestrc files but method redefinitions below and
      # prepending of Statistics is skipped.


      def sample name, &blk
        super name, &blk
        sample_start = @last_sample_stop || Regtest.start
        sample_stop = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        time = sample_stop - sample_start
        @last_sample_stop = sample_stop
        o = OpenStruct.new
        o.sample = name
        o.filename = Regtest.determine_filename_from_caller('.yml')
        o.time = time
        o.source_location = blk.source_location if blk
        Statistics.statistics << o
      end

      def report_statistics
        statistics = Statistics.statistics
        stats = DescriptiveStatistics::Stats.new(statistics.map(&:time))
        sample_count = stats.size
        sample_time_total = stats.sum
        sample_with_max_time = statistics.max_by(&:time)
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        global_time = now - Regtest.start
        report format("\n\n%d samples executed in %.2f s", sample_count, sample_time_total), type: :statistics
        if sample_count > 1
          report format("\nMean:    %.2g s/sample, %d samples/s", stats.mean, 1 / stats.mean), type: :statistics
          report format("Minimum: %.2g s", stats.min), type: :statistics
          report format("Median:  %.2g s", stats.median), type: :statistics
          report format("Maximum: %.2g s", stats.max), type: :statistics

          percentiles = Array(Statistics.percentiles).map(&:to_i)
          if percentiles.size > 0
            report "\n"
            percentiles.each do |per|
              report format("%d%% percentile: %.2g s", per, stats.value_from_percentile(per)), type: :statistics
            end

            percentile_values = percentiles.map {|p| stats.value_from_percentile(p)}.sort
            max = stats.max
            cols = $stdout.respond_to?(:winsize) ? $stdout.winsize[1] : 80
            dots = cols - percentiles.size - 2

            unless dots < 0
              plot = String.new('|')
              last_v = 0
              ([percentile_values] + [max]).flatten.each do |v|
                delta = v - last_v
                last_v = v
                plot << ('-' * (dots / (max / delta.to_f)).round)
                plot << '|'
              end
              report plot, type: :plot
            end
          end

          histogram_slots = Statistics.histogram_slots
          if histogram_slots > 0
            limits = (1..Statistics.histogram_slots).map {|i| max / i}.reverse
            hist = {}
            limits.each {|s| hist[s] = 0}

            stats.each do |s|
              catch :next do
                limits.each do |l|
                  if s <= l
                    hist[l] += 1
                    throw :next
                  end
                end
              end
            end

            scale = (cols.to_f - 2) / stats.size
            report "\n"
            report (hist.keys.map {|k| format('<= %.2g s', k)}.join(', ')), type: :statistics
            hist.each do |k, v|
              bar = '+' * (v * scale).round
              s = format('|%s%s|', bar, ' ' * (cols - 2 - bar.size))
              report (s), type: :plot
            end
          end

          slow_sample_count = Statistics.slow_sample_count
          if slow_sample_count > 0 && sample_count > slow_sample_count
            report format("\n%d slowest samples:", slow_sample_count), type: :statistics
            statistics.sort_by(&:time)[(-1 * slow_sample_count)..-1].each do |stat|
              report format("%p in file %p ran %.2g s", stat.sample, stat.filename, stat.time), type: :statistics
            end
          end
        end

        stat_groups = statistics.group_by(&:source_location)
        stat_groups.delete(nil)
        if stat_groups.size > 1
          report "\nTime for samples by source location"
          sorted_stat_groups = stat_groups.map do |a|
            k, v = a
            [k.to_s, v.sum(&:time)]
          end.sort_by(&:last).reverse
          sorted_stat_groups.each do |a|
            scale = a[1].to_f / sample_time_total
            a[0] =~ /^\["([^"]+)", (\d+)\]$/
            sourcefilename, line = $1, $2
            report format('%s:%d: %.2g %% (%.2g s)', sourcefilename, line, 100.0 * scale, a[1]), type: statistics
          end
          sorted_stat_groups.each do |a|
            scale = a[1].to_f / sample_time_total
            bar = '+' * ((cols - 2) * scale).round
            space = ' ' * ((cols - 2) - bar.size)
            report format('|%s%s|', bar, space), type: :plot
          end
        end

        report format("\nTotal time: %.2f s", global_time), type: :statistics
        report format("Overhead: %.2f s", global_time - sample_time_total), type: :statistics

      end

    end

    class << self
      prepend Statistics
    end

  end
rescue LoadError
  warn 'gem descriptive-statistics is not installed'
  warn 'plugin regtest/statistics disabled'
end