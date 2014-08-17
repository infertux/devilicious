require "bigdecimal"

module Devilicious
  class Money < BigDecimal
    attr_reader :currency

    def initialize(amount, currency)
      @currency = currency

      super(amount)
    end

    def to_s
      sprintf("%.#{decimal_places}f", self) << " " << currency
    end

    def +(other); self.class.new super, currency; end
    def -(other); self.class.new super, currency; end
    def *(other); self.class.new super, currency; end
    def /(other); self.class.new super, currency; end

  private

    def decimal_places
      max = 6 # NOTE: don't care about extra decimals

      2.upto(max) do |i|
        return i if self == self.round(i)
      end

      max
    end
  end
end

