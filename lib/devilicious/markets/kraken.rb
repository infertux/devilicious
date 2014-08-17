module Devilicious
  module Market
    class Kraken < Base
      def fiat_currency
        "EUR"
      end

      def refresh_order_book!
        json = get_json("https://api.kraken.com/0/public/Depth?pair=XBT#{fiat_currency}")

        asks = format_asks_bids(json["result"]["XXBTZ#{fiat_currency}"]["asks"])
        bids = format_asks_bids(json["result"]["XXBTZ#{fiat_currency}"]["bids"])

        Devilicious.log "Order book for #{self} has been refreshed"
        @order_book = OrderBook.new(asks: asks, bids: bids)
      end
    private

      def format_asks_bids(json)
        json.map do |price, volume|
          Offer.new(
            price: Money.new(price, fiat_currency),
            volume: volume
          )
        end
      end
    end
  end
end
