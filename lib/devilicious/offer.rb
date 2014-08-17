require "bigdecimal"

module Devilicious
  class Offer
    attr_accessor :price, :weighted_price, :volume

    def initialize(hash)
      @price = hash.delete(:price)
      @weighted_price = hash.delete(:weighted_price)
      @volume = BigDecimal.new(hash.delete(:volume))

      raise ArgumentError unless hash.empty?
      raise ArgumentError, "#{@price.class} is not Money" unless @price.is_a? Money
    end
  end
end
