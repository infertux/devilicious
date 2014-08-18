module Devilicious
  module Market
    class BitcoinDe < Base
      def fiat_currency
        "EUR"
      end

      def trade_fee
        BigDecimal.new("0.005").freeze # 0.5% - see https://www.bitcoin.de/en/infos#gebuehren
      end

      def refresh_order_book!
        html = get_html("https://www.bitcoin.de/en/market")

        asks = format_asks_bids(html, "offer")
        bids = format_asks_bids(html, "order")

        mark_as_refreshed
        @order_book = OrderBook.new(asks: asks, bids: bids)
      end

    private

      def format_asks_bids(html, type)
        raise unless html.match(/<tbody id="trade_#{type}_results_table_body"(.*)<\/tbody>/m)

        $1.each_line.select { |line| line.include?("data-critical-price") }.map do |line|
          raise unless line.match(/<tr[^>]+data-critical-price="([\d\.]+)" data-amount="([\d\.]+)">/)

          Offer.new(price: Money.new($1, fiat_currency), volume: $2).freeze
        end
      end
    end
  end
end
