module Devilicious
  class Arbitrer
    def markets
      @markets ||= [

        Market::Kraken,
        Market::BitcoinDe,
        # Market::BtcE,

      ].map { |market| market.new }
    end

    def run!
      @market_queue = []
      spawn_observers!

      loop do
        sleep 1 while @market_queue.empty?

        market_1 = @market_queue.shift

        markets.each do |market_2|
          next if market_1 == market_2

          if market_2.order_book.nil?
            Log.debug "Order book for #{market_2} not available yet, skipping"
            next
          end

          # dup everything to avoid race conditions while calculating opportunities
          order_book_1 = market_1.order_book.dup
          order_book_2 = market_2.order_book.dup
          order_book_1.market = market_1.dup
          order_book_2.market = market_2.dup

          Log.debug "Checking opportunity buying from #{market_1} and selling at #{market_2}... "
          if opportunity = check_for_opportunity(order_book_1, order_book_2)
            formatter = Formatter.list[Devilicious.config.formatter]
            formatter.output(opportunity)
          end

          Log.debug "Checking opportunity buying from #{market_2} and selling at #{market_1}... "
          if opportunity = check_for_opportunity(order_book_2, order_book_1)
            formatter = Formatter.list[Devilicious.config.formatter]
            formatter.output(opportunity)
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
            Log.debug "Refreshing order book for #{market}..."
            Thread.new { market.refresh_order_book!; @market_queue << market }
          end

          sleep 20

          alive_threads = threads.select(&:alive?)
          unless alive_threads.empty?
            Log.warn "Timeout for #{alive_threads.size} observer threads"
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
      order_book_1.lowest_ask.price < order_book_2.highest_bid.price
    end

    def check_for_opportunity(order_book_1, order_book_2)
      return unless opportunity?(order_book_1, order_book_2)

      initial_ask_offer = order_book_1.weighted_asks_up_to(order_book_2.highest_bid.price)
      initial_bid_offer = order_book_2.weighted_bids_down_to(order_book_1.lowest_ask.price)

      _dummy = initial_ask_offer.price + initial_bid_offer.price # NOTE: will raise if currency mismatch

      max_volume = [initial_ask_offer.volume, initial_bid_offer.volume].min

      best_offer_limited_volume = find_best_volume(
        order_book_1, order_book_2,
        [max_volume, Devilicious.config.max_volume].min
      )

      best_offer_unlimited_volume = find_best_volume(
        order_book_1, order_book_2,
        [max_volume, BigDecimal.new("22E6")].min
      )

      best_volume = if best_offer_limited_volume.profit > best_offer_unlimited_volume.profit
        best_offer_limited_volume
      else
        best_offer_unlimited_volume
      end.volume

      return if best_offer_limited_volume.profit < Money.new(1, "EUR") # don't care about tiny profits, it's just spam

      best_offer_limited_volume.best_volume = best_volume

      best_offer_limited_volume
    end

    def find_best_volume(order_book_1, order_book_2, max_volume)
      volume = best_volume = BigDecimal.new(Devilicious.config.min_volume)
      best_profit = 0

      while volume < max_volume
        ask_offer = order_book_1.min_ask_price_for_volume(order_book_2.highest_bid.price, volume)
        bid_offer = order_book_2.max_bid_price_for_volume(order_book_1.lowest_ask.price, volume)

        fee = (
          ask_offer.price * order_book_1.market.trade_fee +
          bid_offer.price * order_book_2.market.trade_fee
        ) * volume

        profit = (bid_offer.price - ask_offer.price) * volume - fee

        if profit > best_profit
          best_profit, best_volume, best_profit_fee = profit, volume, fee
        end

        volume += BigDecimal.new("0.1")
      end

      OpenStruct.new(
        order_book_1: order_book_1,
        order_book_2: order_book_2,
        ask_offer: order_book_1.min_ask_price_for_volume(order_book_2.highest_bid.price, best_volume),
        bid_offer: order_book_2.max_bid_price_for_volume(order_book_1.lowest_ask.price, best_volume),
        volume: best_volume,
        profit: best_profit,
        fee: best_profit_fee,
      )
    end
  end
end
