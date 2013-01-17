module DNSResolver
  module Configuration
    extend self

    DEFAULT_OPTIONS = Hashie::Mash.new({
      :nameservers => %w(8.8.8.8 8.8.4.4),
      :log_file => STDOUT,
      :log_age => 86400,
      :log_level => :debug,
      :use_hosts => true,
      :timeout => 1
    })

    def self.extended(base)
      base.reset
    end

    def reset
      self.config = Hashie::Mash.new
      self
    end

    def config=(config)
      if config.kind_of?(IO)
        options = YAML.load(config)
      elsif config.kind_of?(String)
        options = YAML.load(File.read(config))
      elsif config.kind_of?(Hash)
        options = config
      else
        options = {}
      end

      @options = Hashie::Mash.new(DEFAULT_OPTIONS.merge(options))
    end

    def config
      @options
    end

  end
end