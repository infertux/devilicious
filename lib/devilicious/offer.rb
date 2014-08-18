require "bigdecimal"

module Devilicious
  class Offer
    attr_reader :price, :weighted_price, :volume

    def initialize(hash)
      self.price = hash.delete(:price)
      self.weighted_price = hash.delete(:weighted_price)
      self.volume = BigDecimal.new(hash.delete(:volume))

      raise ArgumentError unless hash.empty?
      raise ArgumentError, "#{price.class} is not Money" unless price.is_a? Money
    end

    def inspect
      "#<Devilicious::Offer price=#{price} volume=#{volume.to_f}>"
    end

    def price=(price)
      raise ArgumentError if price < 0
      @price = price
    end

    def weighted_price=(weighted_price)
      raise ArgumentError if weighted_price && weighted_price < 0
      @weighted_price = weighted_price
    end

    def volume=(volume)
      raise ArgumentError if volume < 0
      @volume = volume
    end
  end
end
