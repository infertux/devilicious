module Devilicious
  module Formatter
    class Summary < Base
      def output(opportunity)
        pair = [opportunity.order_book_1.market, " to ", opportunity.order_book_2.market, " " * 4].map(&:to_s).join
        @best_trades ||= {}
        @best_trades[pair] = opportunity

        Log.info "", timestamp: false
        @best_trades.sort_by { |_, opportunity| opportunity.profit }.each do |pair, opportunity|
          Log.info "#{pair} \t#{opportunity.profit} with #{opportunity.volume.to_f} XBT", timestamp: false
        end
      end
    end
  end
end

