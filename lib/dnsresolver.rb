require 'logger'
require 'celluloid/io'
require 'dnsruby'
require 'uuid'
require 'yaml'
require 'active_support/core_ext'
require 'dnsresolver/version'
require 'dnsresolver/config'
require 'dnsresolver/logger'
require 'dnsresolver/exceptions'
require 'dnsresolver/resolver'

module DNSResolver
  extend self

  def generate_uuid
    UUID.generator.generate
  end

  def start!
    dnsresolver = DNSResolver::Resolver.new Config.settings[:nameservers], Config.settings
    Celluloid::Actor[Config.settings[:registry_name].to_sym] = dnsresolver
  end

end