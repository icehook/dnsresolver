module DNSResolver
  class Resolver
    include DNSResolver::Logger
    include DNSResolver::Config
    include DNSResolver::Exceptions

    attr_reader :resolver

    def initialize(options = {})
      @options = Config.settings.merge(options)
      @resolver = Resolv::DNS.new(:nameserver => @options[:nameservers])
    end

    def resolve_naptr(name)
      urls = []

      Fiber.new {
        @resolver.each_resource(name, Resolv::DNS::Resource::IN::NAPTR) do |res|
          regex = res.regex
          c = regex[0,1]
          substr = regex[1,regex.length - 2]
          match, replace = substr.split(c)
          urls << name.gsub(/#{match}/, replace)
        end
      }.resume

      urls
    end

  end
end