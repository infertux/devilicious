module Devilicious
  class CurrencyConverter
    @rates = {}

    def self.convert(amount, from, to)
      amount * rate(from, to)
    end

    def self.rate from, to
      pair = [from, to].join

      if @rates[pair].nil? || @rates[pair].updated_at < Time.now - 10*60

        Log.debug "Refreshing #{pair} rate..."

        @rates[pair] = OpenStruct.new(
          rate: RateExchange.get_rate(from, to),
          updated_at: Time.now
        ).freeze

      end

      @rates[pair].rate
    end

    class RateExchange
      URL = "http://rate-exchange.appspot.com/currency?from=%s&to=%s".freeze

      def self.get_rate(from, to)
        url = URL % [from, to]

        begin
          json = open(url).read
        rescue OpenURI::HTTPError
          retry
        end

        rate = JSON.parse(json)["rate"].to_s
        BigDecimal.new(rate)
      end
    end
  end
end
