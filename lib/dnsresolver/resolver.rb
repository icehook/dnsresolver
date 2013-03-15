module DNSResolver
  class Resolver
    include DNSResolver::Configuration

    attr_reader :resolver, :cache, :use_hosts

    def initialize(options = {})
      @options = DNSResolver.config.merge(options)
      @sockets = []
      @options[:nameservers].each do |ns|
        socket = EventMachine::DnsResolver::DnsSocket.open
        socket.nameserver = ns
        @sockets << socket
      end
      @timeout = @options.timeout
      @use_hosts = @options.use_hosts
      @cache = self.init_cache(:expire_every => @options.cache_expires, :ttl => @options.cache_ttl) if @options.cache
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
      response = nil
      type = options[:type] || 'A'

      logger.debug "attempting to resolve #{name} type #{type} with #{@options[:nameservers].inspect} #{config.inspect}"

      if type == 'A'
        result = resolve_with_cache(name, 'A') if result.blank? && @cache
        result = [name] if result.blank? && self.address?(name)
        result = resolve_with_hosts(name) if result.blank? && @use_hosts

        unless result.blank?
          addresses = result
          response = Response.new nil, addresses, []
        else
          response = self.resolve_a name
          @cache.store name, 'A', response.addresses if !response.addresses.blank? && @cache && !@cache.locked?
        end
      elsif type == 'NAPTR'
        response = self.resolve_naptr name
      end

      response
    end

    def resolve_a(name, options = {})
      socket = options[:socket] || @sockets.sample
      EM::Synchrony.sync self.make_request(socket, name, Resolv::DNS::Resource::IN::A, options)
    end

    def resolve_naptr(name, options = {})
      socket = options[:socket] || @sockets.sample
      EM::Synchrony.sync self.make_request(socket, name, Resolv::DNS::Resource::IN::NAPTR, options)
    end

    def address?(s)
      Resolv::AddressRegex =~ s ? true : false
    end

    protected

      def make_response(request, addresses, errors, options = {})
        Response.new request, addresses, errors, options
      end

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
          a.succeed Response.new(r, results, [], :requested_at => a.created_at)
        }

        r.errback { |e|
          r.cancel_timeout
          a.cancel_timeout
          a.fail Response.new(r, [], [DNSResolverError.new("Problem resolving #{name} #{e}")], :requested_at => a.created_at)
        }

        a
      end

  end
end