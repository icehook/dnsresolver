module DNSResolver
  module Logging

    def logger
      return @logger if defined?(@logger)
      logger = default_logger
      @logger = logger
    end

    def default_logger
      logger = Logger.new(DNSResolver.config[:log_file], DNSResolver.config[:log_age])
      logger.level = "Logger::Severity::#{DNSResolver.config[:log_level].to_s.upcase}".constantize
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{Time.now.iso8601(5)}] ##{Thread.current.object_id} #{severity}: #{msg}\n"
      end
      logger
    end

    def logger=(logger)
      @logger = logger
    end

  end
end
