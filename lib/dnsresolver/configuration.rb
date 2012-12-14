module DNSResolver
  module Configuration
    extend self

    DEFAULT_OPTIONS = {
      :nameservers => %w(8.8.8.8 8.8.4.4),
      :log_file => STDOUT,
      :log_age => 'daily',
      :log_level => :debug
    }.with_indifferent_access

    def self.extended(base)
      base.reset
    end

    def reset
      self.config = HashWithIndifferentAccess.new
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

      @options = DEFAULT_OPTIONS.merge(options).with_indifferent_access
    end

    def config
      @options
    end

  end
end