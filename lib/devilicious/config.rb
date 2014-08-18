module Devilicious
  class Config
    class << self
      def max_volume
        # BigDecimal.new("10").freeze
        BigDecimal.new("5").freeze
      end

      def min_volume
        BigDecimal.new("0.1").freeze
      end
    end
  end
end
