module Devilicious
  module Formatter
    class Table < Base
      def output(opportunity)
        pair = [opportunity.order_book_1.market, " to ", opportunity.order_book_2.market, " " * 4].map(&:to_s).join
        @best_trades ||= {}
        @best_trades[pair] = opportunity

        Log.info "", timestamp: false
        Log.info "PAIR                    \tPROFIT       \tVOLUME \tBUY          \tSELL", timestamp: false
        @best_trades.sort_by { |_, opportunity| opportunity.profit }.each do |pair, opportunity|
          pair = pair.dup << " " * [30 - pair.size, 0].max # padding
          Log.info [pair, opportunity.profit, opportunity.volume.to_f, opportunity.ask_offer.price, opportunity.bid_offer.price].join(" \t"), timestamp: false
        end
      end
    end
  end
end


