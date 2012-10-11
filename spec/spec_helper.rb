$:.push File.expand_path('lib', File.dirname(__FILE__))
require 'bundler/setup'
require 'rspec'
require 'dnsresolver'

include DNSResolver

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each{|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.color_enabled = true
  config.formatter = 'documentation'

  config.before(:suite) do

  end

  config.after(:suite) do

  end

end