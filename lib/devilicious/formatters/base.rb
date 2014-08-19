module Devilicious
  module Formatter
    def self.list
      @list ||= {}
    end

    class Base
      def self.inherited(child)
        formatter = child.new
        Formatter.list[formatter.to_s] = formatter
      end

      def to_s
        self.class.to_s.gsub(/.*::/, "")
      end
    end
  end
end

# Dir["#{__dir__}/**/*.rb"].each do |formatter|
#   require formatter
# end
