module Devilicious
  module Log
    @semaphore ||= Mutex.new

  module_function

    def info message, output = $stdout
      @semaphore.synchronize do
        output.puts "#{Time.now} #{message}"
      end
    end

    def debug message
      info message if Devilicious.debug?
    end

    def warn message
      info "[WARN] #{message}", $stderr
    end
  end
end

