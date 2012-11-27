# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'instrumentable/version'

Gem::Specification.new do |gem|
  gem.name          = "instrumentable"
  gem.version       = Instrumentable::VERSION
  gem.authors       = ["David Tomberlin"]
  gem.email         = ["siyegen@gmail.com"]
  gem.description   = %q{Gem for decorating methods to use with ActiveSupport::Notifications}
  gem.summary       = %q{Gem for decorating methods to use with ActiveSupport::Notifications}
  gem.homepage      = ""

  gem.add_dependency 'activesupport', "~> 3.2"
  gem.add_development_dependency 'minitest'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
