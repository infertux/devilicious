require "bigdecimal"

module Devilicious
  class Money < BigDecimal
    attr_reader :currency

    def initialize(amount, currency)
      @currency = currency

      super(amount)
    end

    def exchange_to new_currency
      new_amount = CurrencyConverter.convert(self, currency, new_currency)

      self.class.new new_amount, new_currency
    end

    def to_s
      sprintf("%.#{decimal_places}f", self) << " " << currency
    end

    def inspect
      "#<Devilicious::Money amount=#{to_s}>"
    end

    def +(other)
      assert_currency! other
      self.class.new super, currency
    end

    def -(other)
      assert_currency! other
      self.class.new super, currency
    end

    def *(other)
      assert_currency! other
      self.class.new super, currency
    end

    def /(other)
      assert_currency! other
      self.class.new super, currency
    end

  private

    def decimal_places
      max = 6 # NOTE: don't care about extra decimals

      2.upto(max) do |i|
        return i if self == self.round(i)
      end

      max
    end

    def assert_currency!(other)
      raise "Currency mismatch: #{self.inspect} #{other.inspect}" if other.is_a?(self.class) && other.currency != currency
    end
  end
end

