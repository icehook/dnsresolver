# -*- encoding: utf-8 -*-
lib = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dnsresolver/version'

Gem::Specification.new do |gem|
  gem.name          = "dnsresolver"
  gem.version       = Dnsresolver::VERSION
  gem.authors       = ["klarrimore"]
  gem.email         = ["klarrimore@icehook.com"]
  gem.description   = %q{A basic DNS resolver}
  gem.summary       = %q{A basic DNS resolver}
  gem.homepage      = "https://github.com/icehook/dnsresolver"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'ffaker', '>= 1.15.0'
  gem.add_development_dependency 'guard-rspec', '~> 2.5.0'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.3'
  gem.add_development_dependency 'simplecov', '~> 0.7.1'
  gem.add_runtime_dependency 'em-resolv-replace', '= 1.1.3'
  gem.add_runtime_dependency 'uuid', '~> 2.3.5'
  gem.add_runtime_dependency 'activesupport', '>= 3.0.0'
  gem.add_runtime_dependency 'em-synchrony', '~> 1.0.3'
  gem.add_runtime_dependency 'hashie', '~> 2.1.1'
  gem.add_runtime_dependency 'dante', '~> 0.1.5'
  gem.add_runtime_dependency 'awesome_print', '~> 1.1.0'
end
