require "devilicious/version"

module Devilicious
  def self.debug?
    ARGV.include?("-d")
  end
end

