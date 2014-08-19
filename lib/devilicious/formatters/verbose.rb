module Devilicious
  module Formatter
    class Verbose < Base
      def output(opportunity)
        fiat_out = opportunity.ask_offer.price * opportunity.volume
        fiat_in = opportunity.bid_offer.price * opportunity.volume

        opportunity.ask_offer.price = opportunity.ask_offer.price.exchange_to(opportunity.order_book_1.market.fiat_currency)
        opportunity.bid_offer.price = opportunity.bid_offer.price.exchange_to(opportunity.order_book_2.market.fiat_currency)

        volume = "#{opportunity.volume.to_f} XBT "
        volume << if opportunity.volume == opportunity.best_volume
          "(BEST VOLUME!)"
        else
          "(best #{opportunity.best_volume.to_f})"
        end

        Log.info \
          "BUY \e[1m#{volume}\e[m from \e[1m#{opportunity.order_book_1.market}\e[m for #{fiat_out} at \e[1m#{opportunity.ask_offer.price}\e[m (#{opportunity.ask_offer.weighted_price} weighted average)" <<
          " and SELL at \e[1m#{opportunity.order_book_2.market}\e[m for #{fiat_in} at \e[1m#{opportunity.bid_offer.price}\e[m (#{opportunity.bid_offer.weighted_price})" <<
          " - PROFIT = \e[1m#{opportunity.profit}\e[m (including #{opportunity.fee} fee)"
      end
    end
  end
end

