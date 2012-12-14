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

    def resolve_naptr(name)
      uris = []

      Fiber.new {
        begin
          @resolver.each_resource(name, Resolv::DNS::Resource::IN::NAPTR) do |res|
            regex = res.regex
            c = regex[0,1]
            substr = regex[1,regex.length - 2]
            match, replace = substr.split(c)
            uris << name.gsub(/#{match}/, replace)
          end
        rescue Exception => e
          logger.warn "Problem resolving #{name}"
          logger.warn e.message
          logger.warn e.backtrace.join("\n")
          raise DNSResolverError, "Error resolving #{name}"
        end
      }.resume

      uris
    end

  end
end