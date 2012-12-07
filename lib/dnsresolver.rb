$:.push File.dirname(__FILE__)
require 'logger'
require 'resolv'
require 'uuid'
require 'yaml'
require 'active_support/core_ext'
require 'eventmachine'
require 'em-resolv-replace'
require 'ext/naptr'
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