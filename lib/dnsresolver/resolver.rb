module DNSResolver
  class Resolver
    include DNSResolver::Logging
    include DNSResolver::Configuration
    include DNSResolver::Exceptions

    attr_reader :resolver

    def initialize(options = {})
      @options = DNSResolver.config.merge(options)
      @resolver = Resolv::DNS.new(:nameserver => @options[:nameservers])
    end

    def resolve(name)
      @resolver.getaddress(name)
    end

    def resolve_naptr(name, &callback)
      uris = []

      EM::DnsResolver::Request.new(EM::DnsResolver.socket, name, Resolv::DNS::Resource::IN::NAPTR).callback { |res|
        regex = res.regex
        c = regex[0,1]
        substr = regex[1,regex.length - 2]
        match, replace = substr.split(c)
        uris << name.gsub(/#{match}/, replace)
      }.errback { |e|
        logger.warn "Problem resolving #{name}"
        logger.warn e
      }.timeout(1, 'timeout')

      uris
    end

  end
end