require "devilicious/markets/base"

module Devilicious
  module Market
    class BtcE < Base
      def fiat_currency
        "EUR"
      end

      def trade_fee
        BigDecimal.new("0.002").freeze # 0.2%
      end

      def refresh_order_book!
        json = get_json("https://btc-e.com/api/2/btc_#{fiat_currency.downcase}/depth") or return

        asks = format_asks_bids(json["asks"])
        bids = format_asks_bids(json["bids"])

        mark_as_refreshed
        @order_book = OrderBook.new(asks: asks, bids: bids)
      end

    private

      def format_asks_bids(json)
        json.map do |price, volume|
          Offer.new(
            price: Money.new(price.to_s, fiat_currency),
            volume: volume.to_s
          ).freeze
        end
      end
    end
  end
end

