$:.push File.dirname(__FILE__)
require 'logger'
require 'ext/naptr'
require 'em-resolv-replace'
require 'uuid'
require 'yaml'
require 'eventmachine'
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

  def create_resolver(options = {})
    @dnsresolver = DNSResolver::Resolver.new Config.settings.merge(options)
  end

end