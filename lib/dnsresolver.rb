require 'logger'
require 'celluloid/io'
require 'dnsruby'
require 'uuid'
require 'dnsresolver/version'
require 'dnsresolver/logger'
require 'dnsresolver/exceptions'
require 'dnsresolver/resolver'

module DNSResolver
  extend self

  DNSRUBY_DEFAULTS = {
                      :query_timeout => 0.5,
                      :do_caching => false,
                      :dnssec => false,
                      :recurse => false
                    }

  def config
    @config
  end

  def config=(config)
    @config = config
  end

  def generate_uuid
    UUID.generator.generate
  end

end