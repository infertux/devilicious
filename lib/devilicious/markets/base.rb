require "open-uri"
require "json"

module Devilicious::Market
  class Base
    attr_reader :order_book

    def to_s
      self.class.to_s.gsub(/.*::/, "")
    end

  private

    def get_html(url)
      begin
        open(url).read
      rescue OpenURI::HTTPError
        retry
      end
    end

    def get_json(url)
      html = get_html(url)
      JSON.parse(html)
    end
  end
end

