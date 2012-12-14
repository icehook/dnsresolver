#$:.push File.expand_path('../../lib', __FILE__)
#$:.push File.expand_path('../../spec', __FILE__)
require 'bundler/setup'
require File.join(File.dirname(__FILE__), '../lib/dnsresolver')

codes_path = File.join(File.dirname(__FILE__), 'samples/codes.csv')

@cfg = {
       :nameservers => ['74.121.83.35'],
       :domain => 'e164.shangovoip.org'
      }

dialcodes = []

File.open(codes_path, 'r').each_line do |line|
  line.strip!
  dialcodes << line
end

DNSResolver.config = @cfg
@resolver = DNSResolver.create_resolver

EM.run {
  dialcodes[0,10].each_with_index do |dialcode,i|
    begin
      name = [dialcode.split('').reverse, @cfg[:domain]].compact.join('.')
      uris = @resolver.resolve_naptr(name)
      puts "index: #{i} name: #{name} #{uris.inspect}"
    rescue Exception => e
      DNSResolver.logger.error e.message
      DNSResolver.logger.error e.backtrace.join("\n")
      EM.stop
    end
  end

  EM.error_handler { |e|
    DNSResolver.logger.error e.message
    DNSResolver.logger.error e.backtrace.join("\n")
    EM.stop
  }
}