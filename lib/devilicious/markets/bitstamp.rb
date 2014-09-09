require "devilicious/markets/base"

module Devilicious
  module Market
    class Bitstamp < Base
      # NOTE: https://www.bitstamp.net/

      def fiat_currency
        "USD"
      end

      def trade_fee
        BigDecimal.new("0.005").freeze # 0.5% - see https://www.bitstamp.net/fee_schedule/
      end

      def refresh_order_book!
        json = get_json("https://www.bitstamp.net/api/order_book/") or return

        asks = format_asks_bids(json["asks"])
        bids = format_asks_bids(json["bids"])

        mark_as_refreshed
        @order_book = OrderBook.new(asks: asks, bids: bids)
      end

    private

      def format_asks_bids(json)
        json.map do |price, volume|
          price_usd = Money.new(price, fiat_currency)
          price_normalized = price_usd.exchange_to(Devilicious.config.default_fiat_currency)

          Offer.new(
            price: price_normalized,
            volume: volume
          ).freeze
        end
      end
    end
  end
end

