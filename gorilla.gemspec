# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gorilla/version'

Gem::Specification.new do |gem|
  gem.name          = "gorilla"
  gem.version       = Gorilla::VERSION
  gem.authors       = ["Nels Broberg"]
  gem.email         = ["nels@rightscale.com"]
  gem.description   = %q{Allows easy source control and creation of RightScale resource}
  gem.summary       = %q{Currently enables copy and automated source control of security groups. Server/deployment creation coming soon... }
  gem.homepage      = "https://github.com/rightscale/gorilla"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rest_connection", "~> 1.0.3"
  gem.add_dependency "trollop"

  gem.add_development_dependency "rake", "~> 0.8.7"
  gem.add_development_dependency "rspec", "~> 2.6.0"              
  gem.add_development_dependency "ruby-debug"
end
