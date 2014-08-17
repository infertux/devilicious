module Devilicious
  module Market
    class BitcoinDe < Base
      def fiat_currency
        "EUR"
      end

      def refresh_order_book!
        html = get_html("https://www.bitcoin.de/en")

        raise unless html.match(/<tbody id="box_buy_sell_offer" class="fs11">\s*<tr[^>]+data-critical-price="([\d\.]+)" data-critical-amount="([\d\.]+)">/m)
        asks = [ Offer.new(price: Money.new($1, fiat_currency), volume: $2) ]

        raise unless html.match(/<tbody id="box_buy_sell_order" class="fs11">\s*<tr[^>]+data-critical-price="([\d\.]+)" data-critical-amount="([\d\.]+)">/m)
        bids = [ Offer.new(price: Money.new($1, fiat_currency), volume: $2) ]
        # FIXME: get other asks/bids

        Devilicious.log "Order book for #{self} has been refreshed"
        @order_book = OrderBook.new(asks: asks, bids: bids)
      end

    private

      # def format_asks_bids(json)
      #   json.map do |price, volume|
      #     Offer.new(price: price, volume: volume)
      #   end
      # end
    end
  end
end
