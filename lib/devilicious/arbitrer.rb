module Devilicious
  class Arbitrer
    def markets
      @markets ||= [Market::Kraken, Market::BitcoinDe].map do |market|
        market.new
      end
    end

    def run!
      spawn_observers!

      loop do
        markets.each do |market_1|
          markets.each do |market_2|
            next if market_1 == market_2

            sleep 5
            # Devilicious.log "Checking opportunity buying from #{market_1} and selling at #{market_2}... "

            order_book_1 = market_1.order_book
            order_book_2 = market_2.order_book

            if order_book_1.nil? || order_book_2.nil?
              Devilicious.log "Order book(s) not available yet, skipping"
              next
            end

            check_for_opportunity(order_book_1.dup, order_book_2.dup)
          end
        end
      end
    end

  private

    def spawn_observers!
      Thread.abort_on_exception = true
      trap("EXIT", -> { Thread.list.each(&:kill) } )

      Thread.new do
        loop do
          threads = markets.map do |market|
            Devilicious.log "Refreshing order book for #{market}..."
            Thread.new { market.refresh_order_book! }
          end

          sleep 60

          alive_threads = threads.select(&:alive?)
          unless alive_threads.empty?
            Devilicious.log "Timeout for threads: #{alive_threads.inspect}"
          end

          threads.each do |thread|
            thread.abort_on_exception = false
            thread.kill
          end

          threads.each(&:join)
        end
      end
    end

    def opportunity?(order_book_1, order_book_2)
      if order_book_1.lowest_ask.price < order_book_2.highest_bid.price
        # Devilicious.log "BUY at #{order_book_1.lowest_ask.price} and SELL at #{order_book_2.highest_bid.price}"
        true
      else
        false
      end
    end

    def check_for_opportunity(order_book_1, order_book_2)
      return unless opportunity?(order_book_1, order_book_2)

      initial_ask_offer = order_book_1.weighted_asks_up_to(order_book_2.highest_bid.price)
      initial_bid_offer = order_book_2.weighted_bids_down_to(order_book_1.lowest_ask.price)
      volume = [initial_ask_offer.volume, initial_bid_offer.volume].min

      raise if initial_ask_offer.price.currency != initial_bid_offer.price.currency # FIXME

      ask_offer = order_book_1.min_ask_price_for_volume(order_book_2.highest_bid.price, volume)
      bid_offer = order_book_2.max_bid_price_for_volume(order_book_1.lowest_ask.price, volume)

      fiat_out = ask_offer.price * volume
      fiat_in = bid_offer.price * volume

      profit = (bid_offer.price - ask_offer.price) * volume
      # profit *= BigDecimal.new("100 - 0.2") / 100 # 0.2% fee

      Devilicious.log "BUY #{volume.to_f} XBT for #{fiat_out} at #{ask_offer.price} (#{ask_offer.weighted_price} weighted average) and SELL for #{fiat_in} at #{bid_offer.price} (#{bid_offer.weighted_price}) - PROFIT = #{profit}"
    end
  end
end
