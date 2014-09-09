require "open-uri"
require "json"
require "retryable"

module Devilicious
  module Market
    class Base
      attr_reader :order_book

      def to_s
        self.class.to_s.gsub(/.*::/, "")
      end

      def trade_fee
        raise NotImplementedError
      end

    private

      def get_html(url)
        begin
          retryable(tries: 5, sleep: 1) do
            open(url).read
          end
        rescue => e
          Log.warn "#{self} error: #{e.inspect}"
        end
      end

      def get_json(url)
        html = get_html(url)
        JSON.parse(html) if html
      end

      def mark_as_refreshed
        Log.debug "Order book for #{self} has been refreshed"
      end
    end
  end
end

