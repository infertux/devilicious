module Devilicious
  module Formatter
    class Summary < Base
      def output(opportunity)
        pair = [opportunity.order_book_1.market, " to ", opportunity.order_book_2.market, " " * 4].map(&:to_s).join
        @best_trades ||= {}
        @best_trades[pair] = opportunity.profit

        Log.info "", timestamp: false
        @best_trades.sort_by(&:last).each do |pair, profit|
          Log.info "#{pair} \t#{profit}", timestamp: false
        end
      end
    end
  end
end

