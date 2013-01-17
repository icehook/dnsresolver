module DNSResolver
  class Resolver
    include DNSResolver::Logging
    include DNSResolver::Configuration
    include DNSResolver::Exceptions

    attr_reader :resolver, :cache

    def initialize(options = {})
      @options = DNSResolver.config.merge(options)
      @socket = EventMachine::DnsResolver::DnsSocket.open
      @socket.nameservers = @options[:nameservers]
      @timeout = @options[:timeout] || 1
      @use_hosts = @options[:use_hosts] || true
      @hosts = Resolv::Hosts.new
      @cache = self.init_cache(:expire_every => @options[:cache_expires], :ttl => @options[:cache_ttl]) if @options[:cache]
      #@resolver = Resolv::DNS.new(:nameserver => @options[:nameservers])
    end

    def init_cache(options = {})
      Cache.new(options)
    end

    def resolve(name, &callback)
      addresses = []

      if @cache
        addresses = @cache.get_addresses name, 'A'
        unless addresses.blank?
          logger.info 'hit cache'
          yield addresses, nil
          return addresses
        end
      end

      if @use_hosts && @hosts
        logger.info 'hit hosts'
        begin
          result = @hosts.getaddresses(name)
          unless result.blank?
            addresses = result
            @cache.store name, 'A', addresses if @cache && !@cache.locked?
            yield addresses, nil
            return addresses
          end
        rescue Exception => e
        end
      end

      EventMachine::DnsResolver::Request.new(@socket, name, Resolv::DNS::Resource::IN::A).callback { |res|
        logger.info 'hit lookup'
        addresses = res
        @cache.store name, 'A', addresses if @cache && !@cache.locked?
        yield addresses, nil
      }.errback { |e|
        yield addresses, DNSResolverError.new("Problem resolving #{name} #{e}")
      }.timeout(@timeout, 'timeout')

      addresses
    end

    def resolve_naptr(name, &callback)
      uris = []

      EventMachine::DnsResolver::Request.new(@socket, name, Resolv::DNS::Resource::IN::NAPTR).callback { |res|
        uris = res
        yield uris, nil
      }.errback { |e|
        yield uris, DNSResolverError.new("Problem resolving #{name} #{e}")
      }.timeout(@timeout, 'timeout')

      uris
    end

  end
end