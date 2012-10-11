$:.push File.expand_path('../', File.dirname(__FILE__))
require 'spec_helper'

describe DNSResolver::Resolver do
  it "can be instantiated" do
    Resolver.new.should be_instance_of Resolver
  end
end
