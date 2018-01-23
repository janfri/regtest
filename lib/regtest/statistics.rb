# encoding: utf-8
# frozen_string_literal: true

require 'regtest'

begin
  require 'descriptive-statistics'

  module Regtest

    @percentiles = []
    @slow_sample_count = 0
    @statistics = []

    module Statistics

      attr_accessor :percentiles, :slow_sample_count

      def sample name
        super name
        sample_start = @last_sample_stop || Regtest.start
        sample_stop = Time.now
        time = sample_stop - sample_start
        @last_sample_stop = sample_stop
        o = OpenStruct.new
        o.sample = name
        o.filename = determine_output_filename
        o.time = time
        statistics << o
      end

      def report_statistics
        stats = DescriptiveStatistics::Stats.new(statistics.map(&:time))
        sample_count = statistics.size
        sample_time_total = stats.sum
        sample_with_max_time = statistics.max_by(&:time)
        global_time = Time.now - Regtest.start
        report format("\n\n%d samples executed in %.2f s", sample_count, sample_time_total), type: :statistics
        if sample_count > 1
          report format("\nMean:   %.2g s/sample, %d samples/s", stats.mean, 1 / stats.mean), type: :statistics
          report format("Median: %.2g s/sample", stats.median), type: :statistics
          report format("Standard deviation: %.2g s", stats.standard_deviation), type: :statistics
          report format("Relative standard deviation: %g", stats.relative_standard_deviation), type: :statistics

          percentiles = Array(Regtest.percentiles).map(&:to_i)
          if percentiles.size > 0
            report "\n"
            percentiles.each do |per|
              report format("%d%% percentile: %.2g s", per, stats.value_from_percentile(per)), type: :statistics
            end
          end

          if Regtest.slow_sample_count > 0 && sample_count > Regtest.slow_sample_count
            report format("\n%d slowest samples:", Regtest.slow_sample_count), type: :statistics
            statistics.sort_by(&:time)[(-1 * Regtest.slow_sample_count)..-1].each do |stat|
              report format("%p in file %p ran %.2g s", stat.sample, stat.filename, stat.time), type: :statistics
            end
          end
        end
        report format("\nTotal time: %.2f s", global_time), type: :statistics
        report format("Overhead: %.2f s", global_time - sample_time_total), type: :statistics

      end

    end

    class << self
      attr_reader :statistics, :slow_sample_count, :percentiles
      prepend Statistics
    end

  end
rescue LoadError
  warn 'gem descriptive-statistics is not installed'
  warn 'plugin regtest/statistics disabled'
end
