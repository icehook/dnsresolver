module DNSResolver
  module Logger

    def logger
      unless @logger
        @logger = ::Logger.new(STDOUT)
        @logger.level = ::Logger::INFO
        Celluloid.logger = @logger
      end

      @logger
    end

    def logger=(logger)
      @logger = logger
      Celluloid.logger = @logger
    end

  end
end
