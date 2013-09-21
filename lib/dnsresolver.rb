$:.push File.dirname(__FILE__)
require 'logger'
require 'hashie'
require 'resolv'
require 'uuid'
require 'yaml'
require 'dante'
require 'awesome_print'
require 'active_support/inflector'
require 'active_support/core_ext/array'
require 'em-synchrony'
require 'em-dns-resolver'
require 'ext/naptr'
require 'ext/monkey_patch'
require 'dnsresolver/version'
require 'dnsresolver/configuration'
require 'dnsresolver/action'
require 'dnsresolver/logging'
require 'dnsresolver/exceptions'
require 'dnsresolver/cache'
require 'dnsresolver/response'
require 'dnsresolver/resolver'

module DNSResolver

  module ClassMethods
    attr_accessor :resolver

    def create_resolver(options = {})
      @resolver = DNSResolver::Resolver.new(options)
    end

    def hosts
      @hosts || init_hosts
    end

    def init_hosts
      @hosts = Resolv::Hosts.new('/etc/hosts')
    end
  end

  def self.init_child_classes
    child_classes.each do |klass|
      klass.send :include, Logging
      klass.send :include, Exceptions
    end
  end

  def self.child_classes
    constants.collect { |c| const_get(c) }.select { |m| m.instance_of?(Class) }
  end

  def self.included(base)
    base.extend(Logging)
    base.extend(Configuration)
    base.extend(ClassMethods)
  end

  extend Logging
  extend Configuration
  extend ClassMethods
  extend self

  init_hosts
  init_child_classes

end