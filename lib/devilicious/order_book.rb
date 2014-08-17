module Devilicious
  class OrderBook
    attr_reader :asks, :bids

    def initialize(hash)
      @asks = hash.delete(:asks).sort_by(&:price).freeze # buy
      @bids = hash.delete(:bids).sort_by(&:price).freeze # sell

      raise ArgumentError unless hash.empty?
    end

    def highest_bid
      bids.last
    end

    def lowest_ask
      asks.first
    end

    def weighted_asks_up_to(max_price)
      weighted_offers(asks, ->(price) { price <= max_price })
    end

    def weighted_bids_down_to(min_price)
      weighted_offers(bids, ->(price) { price >= min_price })
    end

    def min_ask_price_for_volume(max_price, max_volume)
      interesting_asks = interesting_offers(asks, ->(price) { price <= max_price })
      best_offer_price_for_volume(interesting_asks, max_volume)
    end

    def max_bid_price_for_volume(min_price, max_volume)
      interesting_bids = interesting_offers(bids, ->(price) { price >= min_price }).reverse # reverse to start from most expensive
      best_offer_price_for_volume(interesting_bids, max_volume)
    end

  private

    def interesting_offers(offers, condition)
      offers.select { |offer| condition.call(offer.price) }
    end

    def weighted_offers(offers, condition)
      interesting_offers = interesting_offers(offers, condition)

      total_volume = interesting_offers.map(&:volume).inject(:+) || 0
      total_weight_price = interesting_offers.map { |offer| offer.price * offer.volume }.inject(:+) || 0
      weighted_price = total_weight_price / total_volume

      Offer.new(
        price: Money.new(weighted_price, currency),
        volume: total_volume
      )
    end

    def best_offer_price_for_volume(offers, max_volume)
      total_volume = 0
      good_offers = []

      offers.each do |offer|
        if total_volume <= max_volume
          good_offers << offer
          total_volume += offer.volume
        end
      end

      if total_volume > max_volume
        substract_volume = total_volume - max_volume
        good_offers.last.volume -= substract_volume
        total_volume -= substract_volume
      end

      total_weight_price = good_offers.map { |offer| offer.price * offer.volume }.inject(:+) || 0
      weighted_price = total_weight_price / total_volume

      Offer.new(
        price: good_offers.last.price,
        volume: total_volume,
        weighted_price: weighted_price,
      )
    end

    def currency
      lowest_ask.price.currency
    end
  end
end
