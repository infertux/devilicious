require "devilicious/version"

module Devilicious
  @semaphore ||= Mutex.new

  module_function def log message
    @semaphore.synchronize do
      puts "#{Time.now} #{message}"
    end
  end
end

