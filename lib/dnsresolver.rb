$:.push File.dirname(__FILE__)
require 'logger'
require 'hashie'
require 'resolv'
require 'uuid'
require 'yaml'
require 'active_support/core_ext'
require 'eventmachine'
require 'em-dns-resolver'
require 'ext/naptr'
require 'ext/monkey_patch'
require 'dnsresolver/version'
require 'dnsresolver/configuration'
require 'dnsresolver/logging'
require 'dnsresolver/exceptions'
require 'dnsresolver/resolver'

module DNSResolver
  extend self

  def generate_uuid
    UUID.generator.generate
  end

  def create_resolver(options = {})
    @dnsresolver = DNSResolver::Resolver.new options
  end

  def self.included(base)
    base.extend(Logging)
    base.extend(Configuration)
  end

  extend Logging
  extend Configuration

end