module DNSResolver
  class Resolver
    include DNSResolver::Logger
    include DNSResolver::Config
    include DNSResolver::Exceptions
    include Celluloid::IO

    def initialize(nameservers, dnsruby_options = {})
      options = { :config_info => { :nameserver => nameservers[0] }}.merge(Config.dnsruby_settings.merge(dnsruby_options))
      @resolver = Dnsruby::Resolver.new(options)
      self.add_nameservers nameservers
    end

    def resolver
      @resolver
    end

    def add_nameservers(nameservers)
      nameservers.each { |nameserver| @resolver.config.add_nameserver nameserver }
    end

    def perform_query_callback(callback, answers, exception = nil)
      callback.call answers, exception
    end

    def query(name, options = {})
      answers = []
      exception = nil
      record_type = options[:record_type] || Dnsruby::Types.A
      dns_class = options[:dns_class] || Dnsruby::Classes.IN
      callback = options[:callback]

      begin
        q = self.resolver.query(name, record_type, dns_class)
        q.each_answer { |answer| answers << answer }
      rescue Dnsruby::NXDomain => exception
        logger.debug "DNSResolver query, could not resolve '#{name}'"
      rescue Exception => exception
        logger.error "DNSResolver query, '#{name}' #{exception.message}"
      end

      perform_query_callback! callback, answers, exception if callback

      answers
    end

    def naptr_query(name, options = {})
      self.query(name, options.merge(:record_type => Dnsruby::Types.NAPTR))
    end

  end
end