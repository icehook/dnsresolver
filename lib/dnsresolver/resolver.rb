module DNSResolver
  class Resolver
    include DNSResolver::Logging
    include DNSResolver::Configuration
    include DNSResolver::Exceptions

    attr_reader :resolver

    def initialize(options = {})
      @options = DNSResolver.config.merge(options)
      @socket = EventMachine::DnsResolver::DnsSocket.open
      @socket.nameservers = @options[:nameservers]
      @timeout = @options[:timeout] || 1
      @use_hosts = @options[:use_hosts] || true
      @hosts = Resolv::Hosts.new
      #@resolver = Resolv::DNS.new(:nameserver => @options[:nameservers])
    end

    def resolve(name, &callback)
      addresses = []

      if @use_hosts && @hosts
        begin
          result = @hosts.getaddresses(name)
          unless result.blank?
            addresses = result
            yield addresses, nil
            return addresses
          end
        rescue Exception => e
        end
      end

      EventMachine::DnsResolver::Request.new(@socket, name, Resolv::DNS::Resource::IN::A).callback { |res|
        addresses = res
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