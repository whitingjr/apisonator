require 'benchmark/ips'

module ToNotCompactSBenchmark
  module Other
    def old_to_not_compact_s
      strftime('%Y%m%d%H%M%S')
    end

    def new_to_not_compact_s
      (year * 10000000000 + month * 100000000 + day * 1000000 +
       hour * 10000 + min * 100 + sec).to_s
    end
  end

  Time.send :include, Other

  def self.run
    ts = Time.utc(2019, 02, 28, 1, 2, 3)

    Benchmark.ips do |x|
      x.report "old_to_not_compact_s #{ts.inspect}" do
        ts.old_to_not_compact_s
      end
      x.report "new_to_not_compact_s #{ts.inspect}" do
        ts.new_to_not_compact_s
      end
      x.compare!
    end
  end
end

ToNotCompactSBenchmark.run
