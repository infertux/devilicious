module Devilicious
  def self.config
    @config ||= Config.parse(ARGV)
  end
end

