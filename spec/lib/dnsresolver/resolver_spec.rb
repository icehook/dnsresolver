require 'spec_helper'

describe DNSResolver::Resolver do

  let(:options) {
    {
      :nameservers => %w(8.8.8.8 8.8.4.4),
      :log_server => 'debug',
      :use_hosts => false,
      :timeout => 3,
      :cache_ttl => 30,
      :cache => false,
      :cache_expires => 15
    }
  }

  it "can be instantiated" do
    EM.synchrony {
      resolver = Resolver.new(options)
      resolver.should be_instance_of Resolver

      EM.stop
    }
  end

  it "can resolve 'localhost'" do
    EM.synchrony {
      resolver = Resolver.new(options.merge(:use_hosts => true))
      result = resolver.resolve 'localhost', :type => 'A'
      result.addresses.include?('127.0.0.1').should be_true

      EM.stop
    }
  end

  it "can resolve 'google.com'" do
    EM.synchrony {
      resolver = Resolver.new(options)
      result = resolver.resolve 'google.com', :type => 'A'
      result.addresses.should_not be_empty

      EM.stop
    }
  end
end
