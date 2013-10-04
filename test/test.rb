$:.push File.expand_path('../../lib', __FILE__)
#$:.push File.expand_path('../../spec', __FILE__)
require 'bundler/setup'
require File.expand_path('../../lib/dnsresolver', __FILE__)

codes_path = File.expand_path('../samples/codes.csv', __FILE__)

@cfg = {
       :nameservers => ['207.198.118.90'],
       :domain => 'e164.org'
      }

dialcodes = []

File.open(codes_path, 'r').each_line do |line|
  line.strip!
  dialcodes << line
end

EM.synchrony {
  DNSResolver.config = @cfg
  @resolver = DNSResolver.create_resolver
  responses = []

  dialcodes.each_with_index do |dialcode,i|
    next if dialcode.length != 7
    begin
      name = [('1800' + dialcode).split('').reverse, @cfg[:domain]].compact.join('.')
      puts "requesting #{i}"
      response = @resolver.resolve_naptr(name)
      if response.successful?
        puts "index: #{i} name: #{name} #{response.inspect}"
      end
    rescue Exception => e
      DNSResolver.logger.error e.message
      DNSResolver.logger.error e.backtrace.join("\n")
      EM.stop
    end
  end

  puts responses.inspect

  EM.stop

  EM.error_handler { |e|
    DNSResolver.logger.error e.message
    DNSResolver.logger.error e.backtrace.join("\n")
    EM.stop
  }
}