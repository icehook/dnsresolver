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

  gem.add_development_dependency 'rspec', '>= 2.11.0'
  gem.add_development_dependency 'ruby-prof'
  gem.add_development_dependency 'pry'
  gem.add_runtime_dependency 'em-resolv-replace', '= 1.1.3'
  gem.add_runtime_dependency 'uuid', '~> 2.3.5'
  gem.add_runtime_dependency 'activesupport', '>= 3.0.0'
  gem.add_runtime_dependency 'eventmachine', '~> 1.0.0'
  gem.add_runtime_dependency 'hashie', '~> 1.2.0'
end
