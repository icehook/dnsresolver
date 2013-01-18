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

    def resolve(name, &callback)
      addresses = []

      result = resolve_with_cache(name, 'A') if @cache

      result = resolve_with_hosts(name) if result.blank? && @use_hosts

      unless result.blank?
        addresses = result
        @cache.store name, 'A', addresses if @cache && !@cache.locked?
        yield addresses, nil
        return addresses
      else
        r = EventMachine::DnsResolver::Request.new(@sockets.sample, name, Resolv::DNS::Resource::IN::A)

        r.timeout(@timeout, 'timeout')

        r.callback { |res|
          r.cancel_timeout
          addresses = res
          @cache.store name, 'A', addresses if @cache && !@cache.locked?
          yield addresses, nil
        }

        r.errback { |e|
          logger.info 'errback'
          r.cancel_timeout
          yield addresses, DNSResolverError.new("Problem resolving #{name} #{e}")
        }

        return addresses
      end
    end

    def resolve_naptr(name, &callback)
      uris = []

      r = EventMachine::DnsResolver::Request.new(@sockets.sample, name, Resolv::DNS::Resource::IN::NAPTR)

      r.timeout(@timeout, 'timeout')

      r.callback { |res|
        r.cancel_timeout
        uris = res
        yield uris, nil
      }

      r.errback { |e|
        r.cancel_timeout
        yield uris, DNSResolverError.new("Problem resolving #{name} #{e}")
      }

      uris
    end

  end
end