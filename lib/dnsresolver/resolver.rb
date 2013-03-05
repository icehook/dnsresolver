module DNSResolver
  class Resolver
    include DNSResolver::Logging
    include DNSResolver::Configuration
    include DNSResolver::Exceptions

    attr_reader :resolver, :cache, :hosts

    def initialize(options = {})
      @options = DNSResolver.config.merge(options.with_indifferent_access)
      @sockets = []
      @options[:nameservers].each do |ns|
        socket = EventMachine::DnsResolver::DnsSocket.open
        socket.nameserver = ns
        @sockets << socket
      end
      @timeout = @options[:timeout] || 1
      @use_hosts = @options[:use_hosts] || true
      @cache = self.init_cache(:expire_every => @options[:cache_expires], :ttl => @options[:cache_ttl]) if @options[:cache]
      #@resolver = Resolv::DNS.new(:nameserver => @options[:nameservers])
    end

    def init_cache(options = {})
      Cache.new(options)
    end

    def resolve_with_cache(name, type)
      @cache ? @cache.get_addresses(name, type) : []
    end

    def resolve_with_hosts(name)
      DNSResolver.hosts ? DNSResolver.hosts.getaddresses(name) : []
    end

    def resolve(name, options = {}, &callback)
      addresses = []
      type = options[:type] || 'A'

      logger.debug "attempting to resolve #{name} type #{type} with #{@options[:nameservers].inspect}"

      if type == 'A'
        result = resolve_with_cache(name, 'A') if @cache
        result = resolve_with_hosts(name) if result.blank? && @use_hosts

        unless result.blank?
          addresses = result
        else
          addresses = self.resolve_a name
          @cache.store name, 'A', addresses if !addresses.blank? && @cache && !@cache.locked?
        end
      elsif type == 'NAPTR'
        addresses = self.resolve_naptr name
      end

      addresses
    end

    def resolve_a(name, options = {}, &callback)
      results = []

      socket = options[:socket] || @sockets.sample
      results, error = EM::Synchrony.sync self.make_request(socket, name, Resolv::DNS::Resource::IN::A, options)

      logger.warn error.message if error

      results
    end

    def resolve_naptr(name, options = {}, &callback)
      results = []

      socket = options[:socket] || @sockets.sample
      results, error = EM::Synchrony.sync self.make_request(socket, name, Resolv::DNS::Resource::IN::NAPTR, options)

      logger.warn error.message if error

      results
    end

    protected

      def make_request(socket, name, type = Resolv::DNS::Resource::IN::A, options = {})
        timeout = options[:timeout] || @timeout

        a = Action.new

        r = EventMachine::DnsResolver::Request.new(@sockets.sample, Resolv::DNS::Name.create(name), type)
        r.timeout(@timeout, 'timeout')

        a.attributes.request = r
        a.set_timeout(@timeout)

        r.callback { |res|
          r.cancel_timeout
          a.cancel_timeout
          results = res
          a.succeed results, nil
        }

        r.errback { |e|
          r.cancel_timeout
          a.cancel_timeout
          a.fail [], DNSResolverError.new("Problem resolving #{name} #{e}")
        }

        a
      end

  end
end