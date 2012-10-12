module DNSResolver
  module Config
    extend self

    DEFAULTS = {
      :nameservers => %w(8.8.8.8 8.8.4.4),
      :registry_name => 'dnsresolver'
    }

    DNSRUBY_DEFAULTS = {
      :query_timeout => 2,
      :do_caching => true,
      :dnssec => true,
      :recurse => true,
      :port => 53,
      :use_tcp => false,
      :tsig => nil,
      :ignore_truncation => false,
      :src_address => nil,
      :src_port => 0,
      :udp_size => 4096,
      :retry_times => 1,
      :retry_delay => 5,
      :packet_timeout => 5
    }

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

    def dnsruby_settings
      @settings && @settings[:dnsruby] ? DNSRUBY_DEFAULTS.merge(@settings[:dnsruby]) : DNSRUBY_DEFAULTS
    end

    def settings
      @settings ? DEFAULTS.merge(@settings) : DEFAULTS
    end

  end
end