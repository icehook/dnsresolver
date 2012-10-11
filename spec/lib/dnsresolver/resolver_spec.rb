require 'spec_helper'

describe DNSResolver::Resolver do
  it "can be instantiated" do
    Resolver.new(['127.0.0.1']).should be_instance_of Resolver
  end
end
