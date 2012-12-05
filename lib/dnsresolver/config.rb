module DNSResolver
  module Config
    extend self

    DEFAULTS = {
      :nameservers => %w(8.8.8.8 8.8.4.4)
    }.with_indifferent_access

    def load!(path)
      if path.kind_of?(IO)
        file = path
      else
        file = File.open path
      end

      settings = YAML.load(file)
      load_configuration(settings) if settings.present?
      settings
    end

    def load_configuration(settings)
      @settings = settings.with_indifferent_access
    end

    def settings
      @settings ? DEFAULTS.merge(@settings) : DEFAULTS
    end

  end
end