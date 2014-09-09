require "devilicious/markets/base"

module Devilicious
  module Market
    class HitBtc < Base
      # NOTE: https://hitbtc-com.github.io/hitbtc-api/

      def fiat_currency
        "EUR"
      end

      def trade_fee
        BigDecimal.new("0.001").freeze # 0.1% - see https://hitbtc.com/fees-and-limits
      end

      def refresh_order_book!
        json = get_json("https://api.hitbtc.com/api/1/public/BTC#{fiat_currency}/orderbook") or return

        asks = format_asks_bids(json["asks"])
        bids = format_asks_bids(json["bids"])

        mark_as_refreshed
        @order_book = OrderBook.new(asks: asks, bids: bids)
      end

    private

      def format_asks_bids(json)
        json.map do |price, volume|
          Offer.new(
            price: Money.new(price, fiat_currency),
            volume: volume
          ).freeze
        end
      end
    end
  end
end


