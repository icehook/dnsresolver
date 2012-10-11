# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dnsresolver/version'

Gem::Specification.new do |gem|
  gem.name          = "dnsresolver"
  gem.version       = Dnsresolver::VERSION
  gem.authors       = ["klarrimore"]
  gem.email         = ["klarrimore@icehook.com"]
  gem.description   = %q{A basic dns resolver using Celluloid}
  gem.summary       = %q{A basic dns resolver using Celluloid}
  gem.homepage      = "https://github.com/icehook/dnsresolver"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency 'rspec', '>= 2.11.0'
  gem.add_development_dependency 'ruby-prof'
  gem.add_runtime_dependency 'celluloid-io', '>= 0.12.0'
  gem.add_runtime_dependency 'dnsruby', '~> 1.53'
  gem.add_runtime_dependency 'uuid', '~> 2.3.5'
end
