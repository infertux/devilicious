require 'optparse'
require 'ostruct'

module Devilicious
  class Config
    def self.parse(args)
      config = OpenStruct.new
      config.debug = false
      config.verbose = false
      config.formatter = "Verbose"
      config.max_volume = BigDecimal.new("10").freeze
      config.min_volume = BigDecimal.new("0.1").freeze
      config.default_fiat_currency = "EUR".freeze # ideally the most used currency so we do as little conversions as possible

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: devilicious [config]"

        opts.separator ""
        opts.separator "Specific config:"

        opts.on("-v", "--verbose", "Run verbosely") do |v|
          config.verbose = v
        end

        opts.on("-d", "--debug", "Debug mode") do |d|
          config.debug = d
        end

        opts.on("-f", "--formatter [TYPE]", %w(Verbose Summary),
                "Select formatter (#{Formatter.list.keys.sort.join(", ")})") do |f|
          config.formatter = f
        end

        opts.separator ""
        opts.separator "Common config:"

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end

      opt_parser.parse!(args)
      config
    end
  end
end

